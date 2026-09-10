import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _landCtrl = TextEditingController();

  String _soilType = 'Black';
  String _cropType = 'Cotton';
  bool _busy = false;

  final _soilTypes = ['Black', 'Red', 'Alluvial', 'Laterite', 'Other'];
  final _cropTypes = ['Cotton', 'Wheat', 'Rice', 'Sugarcane', 'Soybean', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _villageCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _landCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => _busy = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameCtrl.text.trim());
    await prefs.setString('profile_phone', _phoneCtrl.text.trim());
    await prefs.setString('profile_village', _villageCtrl.text.trim());
    await prefs.setString('profile_district', _districtCtrl.text.trim());
    await prefs.setString('profile_state', _stateCtrl.text.trim());
    await prefs.setString('profile_land', _landCtrl.text.trim());
    await prefs.setString('profile_soil', _soilType);
    await prefs.setString('profile_crop', _cropType);

    if (mounted) context.go('/onboarding/permissions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgroviaColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('Tell us a bit about yourself and your farm', style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AgroviaColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AgroviaColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.person_pin, color: AgroviaColors.primary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Personal Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.primary)),
                      const SizedBox(height: 16),
                      _buildTextField(_nameCtrl, 'Full Name', Icons.person_outline),
                      const SizedBox(height: 12),
                      _buildTextField(_phoneCtrl, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),

                      const SizedBox(height: 24),
                      const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.primary)),
                      const SizedBox(height: 16),
                      _buildTextField(_villageCtrl, 'Village / City', Icons.location_city_outlined),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_districtCtrl, 'District', Icons.map_outlined)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(_stateCtrl, 'State', Icons.explore_outlined)),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text('Farm Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.primary)),
                      const SizedBox(height: 16),
                      _buildTextField(_landCtrl, 'Land Size (e.g., 5 Acres)', Icons.landscape_outlined),
                      const SizedBox(height: 12),
                      _buildDropdown('Soil Type', Icons.grass_outlined, _soilTypes, _soilType, (v) => setState(() => _soilType = v!)),
                      const SizedBox(height: 12),
                      _buildDropdown('Primary Crop', Icons.agriculture_outlined, _cropTypes, _cropType, (v) => setState(() => _cropType = v!)),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _busy ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _busy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AgroviaColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AgroviaColors.textSecondary),
        prefixIcon: Icon(icon, color: AgroviaColors.textSecondary, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AgroviaColors.glassBorderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgroviaColors.primary)),
      ),
    );
  }

  Widget _buildDropdown(String hint, IconData icon, List<String> options, String value, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgroviaColors.glassBorderDark),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        icon: const Icon(Icons.arrow_drop_down, color: AgroviaColors.textSecondary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AgroviaColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dropdownColor: AgroviaColors.backgroundDark,
        style: const TextStyle(color: AgroviaColors.textPrimary, fontSize: 16),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
