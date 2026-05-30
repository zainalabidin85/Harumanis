import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tree.dart';
import '../services/api_service.dart';
import '../widgets/page_route.dart';
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
  bool _buttonPressed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller =
        CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      if (detail != null) {
        if (detail.contains('No hand')) {
          return 'No hand detected. Hold your open palm beside the fruit.';
        }
        if (detail.contains('No mango')) {
          return 'No mangoes detected. Try again with better lighting.';
        }
        return detail;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Check your internet and try again.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Cannot reach server. Check your internet connection.';
      }
    }
    if (e is DioException) {
      return 'Error ${e.response?.statusCode ?? "?"}: ${e.type.name}';
    }
    return 'Error: ${e.runtimeType}';
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    HapticFeedback.mediumImpact();
    setState(() { _uploading = true; _error = null; });
    try {
      final file = await _controller!.takePicture();
      final result =
          await ApiService.detectMangoes(widget.tree.id, file.path);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeSlideRoute(page: ResultScreen(result: result, imagePath: file.path)),
        );
      }
    } catch (e) {
      HapticFeedback.vibrate();
      setState(() { _error = _errorMessage(e); });
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Camera preview ──────────────────────────────────────────
            if (_controller?.value.isInitialized == true)
              CameraPreview(_controller!)
            else
              const Center(
                  child:
                      CircularProgressIndicator(color: Colors.white)),

            // ── Top overlay — title + close ─────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          'Tree ${widget.tree.treeNumber}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom overlay — hint + shutter ─────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      children: [
                        // Hint
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Point at ONE mango. Hold your open palm beside it, then tap Capture.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        // Shutter button
                        _ShutterButton(
                          uploading: _uploading,
                          pressed: _buttonPressed,
                          onTapDown: () =>
                              setState(() => _buttonPressed = true),
                          onTapUp: () =>
                              setState(() => _buttonPressed = false),
                          onTap: _uploading ? null : _capture,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool uploading;
  final bool pressed;
  final VoidCallback? onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _ShutterButton({
    required this.uploading,
    required this.pressed,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      onTap: onTap,
      child: AnimatedScale(
        scale: pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3.5),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: pressed ? 52 : 60,
              height: pressed ? 52 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: uploading
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white,
              ),
              child: uploading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
