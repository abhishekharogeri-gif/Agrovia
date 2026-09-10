import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _userEmail;
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
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final pos = await _resolvePosition();
    final weather = await _weatherService.fetchWeather(
      lat: pos?.latitude,
      lon: pos?.longitude,
    );

    if (mounted) {
      setState(() {
        _userName = prefs.getString('profile_name') ?? user?.displayName ?? (user?.email != null ? user!.email!.split('@')[0] : 'Farmer');
        _userEmail = user?.email ?? user?.phoneNumber;
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
      backgroundColor: AgroviaColors.backgroundDark,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userName ?? 'Farmer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AgroviaColors.textPrimary),
            ),
            const Text(
              'Agrovia Dashboard',
              style: TextStyle(fontSize: 11, color: AgroviaColors.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AgroviaColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications'), duration: Duration(seconds: 1)),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined, color: AgroviaColors.textPrimary),
            color: AgroviaColors.backgroundDark,
            onSelected: (value) {
              if (value == 'profile') context.go('/profile');
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              if (_userEmail != null)
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userEmail!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AgroviaColors.textPrimary)),
                      const Text('Active Session', style: TextStyle(fontSize: 11, color: AgroviaColors.textSecondary)),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'profile',
                child: Row(children: [Icon(Icons.person_outline_rounded, size: 18, color: AgroviaColors.primary), SizedBox(width: 8), Text('My Profile', style: TextStyle(color: AgroviaColors.textPrimary))]),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout, size: 18, color: AgroviaColors.accentDanger), SizedBox(width: 8), Text('Sign Out', style: TextStyle(color: AgroviaColors.accentDanger))]),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AgroviaColors.primary))
          : RefreshIndicator(
              color: AgroviaColors.primary,
              backgroundColor: AgroviaColors.backgroundDark,
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
                              _weatherData?['city'] != null
                                  ? '${_weatherData!['city']}, ${_weatherData!['country'] ?? 'IN'}'
                                  : 'Indore, IN',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_weatherData?['temp'] ?? 28}°C • ${_weatherData?['description'] ?? 'Clear Sky'}',
                              style: const TextStyle(color: AgroviaColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AgroviaColors.accentGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AgroviaColors.accentGreen.withValues(alpha: 0.3)),
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
                          _weatherService.getWeatherIcon(_weatherData?['icon'] as String?),
                          style: const TextStyle(fontSize: 40),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Farm & Crops Overview
                  const Text('Your Crops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go('/vision-x'),
                          child: GlassContainer(
                            child: Column(
                              children: const [
                                Icon(Icons.grass_rounded, color: AgroviaColors.primary, size: 32),
                                SizedBox(height: 8),
                                Text('Soybean', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
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
                              Text('Wheat', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                              Text('2.0 Acres • Sowing', style: TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Mandi Price Highlight
                  const Text('Market Spot Rates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.go('/market'),
                    child: GlassContainer(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AgroviaColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.trending_up, color: AgroviaColors.primary),
                        ),
                        title: const Text('Soybean (Yellow)', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                        subtitle: const Text('Indore Mandi • 12km away', style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 13)),
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
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AgroviaColors.accentDanger.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.trending_down_rounded, color: AgroviaColors.accentDanger),
                        ),
                        title: const Text('Cotton (BT)', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                        subtitle: const Text('Guntur Mandi • AP', style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 13)),
                        trailing: const Text('₹7,150/q', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.accentDanger)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Action Grid
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildImageAction('assets/icons/vision_x.png', 'Scan Crop', AgroviaColors.primary, () => context.go('/vision-x'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(Icons.people_rounded, 'Kisan Connect', AgroviaColors.primary, () => context.go('/connect'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildQuickAction(Icons.policy_rounded, 'Yojana Hub', AgroviaColors.accentGreen, () => context.go('/yojana-hub'))),
                    ],
                  ),
                  const SizedBox(height: 80),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAction(String imagePath, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset(imagePath, width: 24, height: 24, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
