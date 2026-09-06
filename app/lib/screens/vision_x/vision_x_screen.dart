import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../theme/agrovia_theme.dart';
import '../../widgets/glass_container.dart';
import '../../services/vision_x_service.dart';
import 'diagnosis_result_screen.dart';

class VisionXScreen extends StatefulWidget {
  const VisionXScreen({super.key});

  @override
  State<VisionXScreen> createState() => _VisionXScreenState();
}

class _VisionXScreenState extends State<VisionXScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 0;
  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    VisionXService().initModel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _setupCameraController(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('VisionX: Error getting cameras: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('VisionX: Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('VisionX: Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _captureAndDiagnose() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      String imagePath = 'mock_path.jpg';
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile file = await _cameraController!.takePicture();
        imagePath = file.path;
      }

      final diag = await VisionXService().diagnoseImage(imagePath);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiagnosisResultScreen(result: diag),
          ),
        );
      }
    } catch (e) {
      debugPrint('VisionX: Capture failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Diagnosis failed: $e')),
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
          // Camera Preview or Simulated Viewfinder
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            Container(
              color: Colors.grey.shade900,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Icon(Icons.qr_code_scanner_rounded, size: 250, color: Colors.white24),
              ),
            ),

          // Viewfinder Target Overlay
          if (!_isProcessing)
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AgroviaColors.primary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
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
                    Text(
                      'Analyzing leaf sample...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Running on-device MobileNetV2 TFLite (29 classes)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
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
                  children: [
                    const Text(
                      'Vision X Diagnostics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: _isFlashOn ? Colors.amber : Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Control Panel
          if (!_isProcessing)
            Positioned(
              bottom: 110,
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
                      'Align diseased plant leaf inside frame',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.grey.shade900,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Best Diagnosis Tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(height: 10),
                                    Text('• Keep the camera steady and 15-20cm away from the leaf.', style: TextStyle(color: Colors.white70)),
                                    SizedBox(height: 6),
                                    Text('• Ensure adequate natural or flash lighting.', style: TextStyle(color: Colors.white70)),
                                    SizedBox(height: 6),
                                    Text('• Avoid multiple overlapping leaves or noisy backgrounds.', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: _captureAndDiagnose,
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3.5),
                              color: AgroviaColors.primaryDark.withValues(alpha: 0.85),
                            ),
                            child: const Center(
                              child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
                          onPressed: _switchCamera,
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
