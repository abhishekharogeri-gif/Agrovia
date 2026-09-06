import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../services/weather_service.dart';
import '../../widgets/glass_container.dart';
import '../../theme/agrovia_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  String? _userPhone;
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  Position? _position;
  Timer? _refreshTimer;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // ponytail: 15-min background refresh; cancel on dispose
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) => _refreshWeather());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<Position?> _resolvePosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final pos = await _resolvePosition();
    final weather = await _weatherService.fetchWeather(
      lat: pos?.latitude,
      lon: pos?.longitude,
    );

    if (mounted) {
      setState(() {
        _userName = user?.displayName ?? user?.phoneNumber ?? 'Farmer';
        _userPhone = user?.phoneNumber;
        _position = pos;
        _weatherData = weather;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshWeather() async {
    final weather = await _weatherService.fetchWeather(
      lat: _position?.latitude,
      lon: _position?.longitude,
    );
    if (mounted && weather != null) {
      setState(() => _weatherData = weather);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userName ?? 'Farmer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'Agrovia Dashboard',
              style: TextStyle(fontSize: 11, color: AgroviaColors.textSecondary, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications'), duration: Duration(seconds: 1)),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'profile') context.go('/profile');
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              if (_userPhone != null)
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userPhone!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('Logged in via OTP', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'profile',
                child: Row(children: [Icon(Icons.person_outline_rounded, size: 18), SizedBox(width: 8), Text('My Profile')]),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout, size: 18, color: Colors.red), SizedBox(width: 8), Text('Sign Out', style: TextStyle(color: Colors.red))]),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Weather & Advisory Glass Card
                  GlassContainer(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _weatherData?['name'] != null ? '${_weatherData!['name']}, IN' : 'Indore, MP',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_weatherData?['main']?['temp']?.round() ?? 28}°C • ${_weatherData?['weather']?[0]?['description'] ?? 'Clear Sky'}',
                              style: const TextStyle(color: AgroviaColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AgroviaColors.accentGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _weatherData != null
                                    ? _weatherService.getSprayAdvisory(_weatherData!)
                                    : 'Good Spray Window: 4 PM',
                                style: const TextStyle(fontSize: 12, color: AgroviaColors.accentGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _weatherService.getWeatherIcon(_weatherData?['weather']?[0]?['icon'] as String?),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Farm & Crops Overview
                  const Text('Your Crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/vision-x'),
                          child: GlassContainer(
                            child: Column(
                              children: const [
                                Icon(Icons.grass_rounded, color: AgroviaColors.primaryDark, size: 32),
                                SizedBox(height: 8),
                                Text('Soybean', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('4.5 Acres • Vegetative', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassContainer(
                          child: Column(
                            children: const [
                              Icon(Icons.eco_rounded, color: AgroviaColors.accentGreen, size: 32),
                              SizedBox(height: 8),
                              Text('Wheat', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('2.0 Acres • Sowing', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Mandi Price Highlight
                  const Text('Market Spot Rates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/market'),
                    child: GlassContainer(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AgroviaColors.primaryLight,
                          child: Icon(Icons.trending_up, color: AgroviaColors.primaryDark),
                        ),
                        title: const Text('Soybean (Yellow)', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Indore Mandi • 12km away'),
                        trailing: const Text('₹4,850/q', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.accentGreen)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.go('/market'),
                    child: GlassContainer(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[50],
                          child: Icon(Icons.trending_down_rounded, color: Colors.red[700]),
                        ),
                        title: const Text('Cotton (BT)', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Guntur Mandi • AP'),
                        trailing: Text('₹7,150/q', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[700])),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Grid
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildQuickAction(Icons.camera_alt_rounded, 'Scan Crop', AgroviaColors.primaryDark, () => context.go('/vision-x'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(Icons.people_rounded, 'Kisan Connect', AgroviaColors.primaryDark, () => context.go('/connect'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(Icons.policy_rounded, 'Yojana Hub', AgroviaColors.accentGreen, () => context.go('/yojana-hub'))),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
