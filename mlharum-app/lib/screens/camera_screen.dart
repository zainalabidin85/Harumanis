import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/tree.dart';
import '../models/fruit.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final Tree tree;
  const CameraScreen({super.key, required this.tree});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
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
    setState(() { _uploading = true; _error = null; });

    try {
      final file = await _controller!.takePicture();
      final result = await ApiService.detectMangoes(widget.tree.id, file.path);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString().contains('No hand')
          ? 'No hand detected. Hold your open palm beside the fruit.'
          : e.toString().contains('No mango')
              ? 'No mangoes detected. Try again with better lighting.'
              : 'Upload failed. Check your connection.';
      });
    } finally {
      setState(() { _uploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Tree ${widget.tree.treeNumber}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller?.value.isInitialized == true
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
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Hold your open palm beside the fruit, then tap Capture',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.orange), textAlign: TextAlign.center),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _capture,
              icon: _uploading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.camera_alt, color: Colors.white),
              label: Text(
                _uploading ? 'Analysing...' : 'Capture',
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
