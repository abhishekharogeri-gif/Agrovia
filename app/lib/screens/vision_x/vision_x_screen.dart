import 'package:flutter/material.dart';
import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';
import '../../services/vision_x_service.dart';
import 'diagnosis_result_screen.dart';

class VisionXScreen extends StatefulWidget {
  const VisionXScreen({super.key});

  @override
  State<VisionXScreen> createState() => _VisionXScreenState();
}

class _VisionXScreenState extends State<VisionXScreen> {
  bool _isProcessing = false;

  Future<void> _captureAndDiagnose() async {
    setState(() => _isProcessing = true);
    try {
      final diag = await VisionXService().diagnoseImage('mock_path.jpg');
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiagnosisResultScreen(result: diag),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Preview
          Container(
            color: Colors.grey.shade900,
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Icon(Icons.qr_code_scanner_rounded, size: 250, color: Colors.white24),
            ),
          ),

          // Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: AgroviaColors.primary),
                    SizedBox(height: 16),
                    Text('Analyzing plant health...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Running on-device TFLite models', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

          // Header
          if (!_isProcessing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Vision X Diagnostics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Icon(Icons.flash_off_rounded),
                  ],
                ),
              ),
            ),

          // Bottom Control Panel
          if (!_isProcessing)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: GlassContainer(
                blur: 24,
                surfaceColor: Colors.white.withValues(alpha: 0.1),
                borderColor: Colors.white.withValues(alpha: 0.3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Center leaf in frame',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                          onPressed: _captureAndDiagnose, // In prod: open gallery
                        ),
                        GestureDetector(
                          onTap: _captureAndDiagnose,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: AgroviaColors.primaryDark.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
