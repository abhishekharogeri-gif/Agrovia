import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController(text: 'Madhya Pradesh');
  final _landCtrl = TextEditingController();
  final _soilCtrl = TextEditingController(text: 'Black Cotton');
  String _primaryCrop = 'Soybean';
  bool _loading = true;

  static const _crops = ['Soybean', 'Wheat', 'Cotton', 'Maize', 'Paddy', 'Gram', 'Mustard'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _nameCtrl.text = user?.displayName ?? prefs.getString('profile_name') ?? '';
      _villageCtrl.text = prefs.getString('profile_village') ?? '';
      _districtCtrl.text = prefs.getString('profile_district') ?? 'Indore';
      _landCtrl.text = prefs.getString('profile_land') ?? '';
      _primaryCrop = prefs.getString('profile_crop') ?? 'Soybean';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameCtrl.text.trim());
    await prefs.setString('profile_village', _villageCtrl.text.trim());
    await prefs.setString('profile_district', _districtCtrl.text.trim());
    await prefs.setString('profile_state', _stateCtrl.text.trim());
    await prefs.setString('profile_land', _landCtrl.text.trim());
    await prefs.setString('profile_soil', _soilCtrl.text.trim());
    await prefs.setString('profile_crop', _primaryCrop);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _villageCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _landCtrl.dispose();
    _soilCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassContainer(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AgroviaColors.primaryLight,
                        child: Text(
                          (_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : (user?.phoneNumber ?? 'F')[0]).toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AgroviaColors.primaryDark),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_nameCtrl.text.isEmpty ? 'Farmer' : _nameCtrl.text,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(user?.phoneNumber ?? 'Not signed in',
                                style: const TextStyle(fontSize: 13, color: AgroviaColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Farm Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _field('Full Name', _nameCtrl, required: true),
                        _field('Village', _villageCtrl),
                        _field('District', _districtCtrl, required: true),
                        _field('State', _stateCtrl),
                        _field('Total Land (Acres)', _landCtrl, keyboardType: TextInputType.number),
                        _field('Soil Type', _soilCtrl),
                        const SizedBox(height: 12),
                        const Text('Primary Crop',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _primaryCrop,
                          items: _crops
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _primaryCrop = v ?? 'Soybean'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save_rounded, color: Colors.white),
                            label: const Text('Save Profile', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AgroviaColors.primaryDark,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: _logout,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label required' : null : null,
      ),
    );
  }
}
