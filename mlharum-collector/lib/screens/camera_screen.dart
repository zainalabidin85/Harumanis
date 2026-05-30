import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'annotation_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() { _error = 'No camera found on this device.'; });
      return;
    }
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() { _capturing = true; _error = null; });
    try {
      final file = await _controller!.takePicture();
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnnotationScreen(imagePath: file.path)),
        );
      }
    } catch (e) {
      setState(() { _error = 'Failed to capture. Try again.'; });
    } finally {
      if (mounted) setState(() { _capturing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Mango'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.orange)))
                : _controller?.value.isInitialized == true
                    ? Stack(
                        children: [
                          CameraPreview(_controller!),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Hold your palm open beside the mango on the tree, then tap Capture',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _capturing ? null : _capture,
              icon: _capturing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                _capturing ? 'Capturing...' : 'Capture',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
