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
      _nameCtrl.text = prefs.getString('profile_name') ?? user?.displayName ?? '';
      _villageCtrl.text = prefs.getString('profile_village') ?? '';
      _districtCtrl.text = prefs.getString('profile_district') ?? 'Indore';
      _stateCtrl.text = prefs.getString('profile_state') ?? 'Madhya Pradesh';
      _landCtrl.text = prefs.getString('profile_land') ?? '';
      _soilCtrl.text = prefs.getString('profile_soil') ?? 'Black Cotton';
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
      const SnackBar(content: Text('Profile saved successfully!'), duration: Duration(seconds: 2)),
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
    final displayName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (user?.displayName ?? 'Farmer');
    final emailOrPhone = user?.email ?? user?.phoneNumber ?? 'Signed In';

    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AgroviaColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AgroviaColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AgroviaColors.primary, AgroviaColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: AgroviaColors.glassBorderDark, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (displayName.isNotEmpty ? displayName[0] : 'F').toUpperCase(),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              emailOrPhone,
                              style: const TextStyle(fontSize: 13, color: AgroviaColors.textSecondary),
                            ),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farm & Personal Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.primary),
                        ),
                        const SizedBox(height: 16),
                        _field('Full Name', _nameCtrl, Icons.person_outline, required: true),
                        _field('Village / City', _villageCtrl, Icons.location_city_outlined),
                        _field('District', _districtCtrl, Icons.map_outlined, required: true),
                        _field('State', _stateCtrl, Icons.explore_outlined),
                        _field('Total Land (Acres)', _landCtrl, Icons.landscape_outlined, keyboardType: TextInputType.number),
                        _field('Soil Type', _soilCtrl, Icons.grass_outlined),
                        const SizedBox(height: 8),
                        const Text(
                          'Primary Crop',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AgroviaColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AgroviaColors.glassBorderDark),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _primaryCrop,
                            dropdownColor: AgroviaColors.backgroundDark,
                            style: const TextStyle(color: AgroviaColors.textPrimary, fontSize: 15),
                            icon: const Icon(Icons.arrow_drop_down, color: AgroviaColors.textSecondary),
                            items: _crops
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => _primaryCrop = v ?? 'Soybean'),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.agriculture_outlined, color: AgroviaColors.textSecondary, size: 20),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                            label: const Text('Save Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AgroviaColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AgroviaColors.accentDanger),
                    title: const Text('Sign Out', style: TextStyle(color: AgroviaColors.accentDanger, fontWeight: FontWeight.bold)),
                    onTap: _logout,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: AgroviaColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AgroviaColors.textSecondary),
          prefixIcon: Icon(icon, color: AgroviaColors.textSecondary, size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AgroviaColors.glassBorderDark)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.primary)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label required' : null : null,
      ),
    );
  }
}
