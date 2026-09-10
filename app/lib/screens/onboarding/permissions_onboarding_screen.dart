import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';

class PermissionsOnboardingScreen extends StatefulWidget {
  const PermissionsOnboardingScreen({super.key});

  @override
  State<PermissionsOnboardingScreen> createState() => _PermissionsOnboardingScreenState();
}

class _PermissionsOnboardingScreenState extends State<PermissionsOnboardingScreen> {
  bool _cameraGranted = false;
  bool _micGranted = false;
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final camera = await Permission.camera.status.isGranted;
    final mic = await Permission.microphone.status.isGranted;
    final location = await Permission.locationWhenInUse.status.isGranted;

    if (mounted) {
      setState(() {
        _cameraGranted = camera;
        _micGranted = mic;
        _locationGranted = location;
      });
    }
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    setState(() => _cameraGranted = status.isGranted);
  }

  Future<void> _requestMic() async {
    final status = await Permission.microphone.request();
    setState(() => _micGranted = status.isGranted);
  }

  Future<void> _requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    setState(() => _locationGranted = status.isGranted);
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
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AgroviaColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AgroviaColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.security_rounded, color: AgroviaColors.primary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('App Permissions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Agrovia needs these permissions to provide you with crop disease detection, voice assistance, and local weather.',
                    style: TextStyle(color: AgroviaColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildPermissionCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      desc: 'Scan crops for disease detection',
                      isGranted: _cameraGranted,
                      onRequest: _requestCamera,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.mic_none_outlined,
                      title: 'Microphone',
                      desc: 'Talk to Saanvi AI voice assistant',
                      isGranted: _micGranted,
                      onRequest: _requestMic,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      desc: 'Get local weather & mandi prices',
                      isGranted: _locationGranted,
                      onRequest: _requestLocation,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgroviaColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Start Using Agrovia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      surfaceColor: isGranted ? AgroviaColors.accentGreen.withValues(alpha: 0.1) : null,
      borderColor: isGranted ? AgroviaColors.accentGreen.withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isGranted ? AgroviaColors.accentGreen : AgroviaColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isGranted ? AgroviaColors.accentGreen : AgroviaColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AgroviaColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AgroviaColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isGranted)
            const Icon(Icons.check_circle_rounded, color: AgroviaColors.accentGreen)
          else
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                backgroundColor: AgroviaColors.primary.withValues(alpha: 0.1),
                foregroundColor: AgroviaColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Allow'),
            ),
        ],
      ),
    );
  }
}
