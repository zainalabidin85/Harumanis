import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/page_route.dart';
import 'pulp_result_screen.dart';
import '../l10n/l10n.dart';

class PulpCameraScreen extends StatefulWidget {
  const PulpCameraScreen({super.key});

  @override
  State<PulpCameraScreen> createState() => _PulpCameraScreenState();
}

class _PulpCameraScreenState extends State<PulpCameraScreen> {
  CameraController? _controller;
  bool _capturing = false;
  bool _buttonPressed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _error = context.l10n.pulpErrorNoCamera);
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
    HapticFeedback.mediumImpact();
    setState(() { _capturing = true; _error = null; });
    try {
      final file = await _controller!.takePicture();
      if (mounted) {
        await Navigator.push(
          context,
          FadeSlideRoute(page: PulpResultScreen(imagePath: file.path)),
        );
      }
    } catch (_) {
      setState(() => _error = context.l10n.pulpErrorCapture);
    } finally {
      if (mounted) setState(() => _capturing = false);
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
            if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(_error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.orange, fontSize: 14)),
                ),
              )
            else if (_controller?.value.isInitialized == true)
              Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(_controller!),
                  CustomPaint(
                    painter: _GuideOverlayPainter(),
                    child: const SizedBox.expand(),
                  ),
                ],
              )
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),

            // ── Top overlay ─────────────────────────────────────────────
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
                          context.l10n.pulpCameraTitle,
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

            // ── Bottom overlay ──────────────────────────────────────────
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.pulpCameraInstruction,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _ShutterButton(
                          capturing: _capturing,
                          pressed: _buttonPressed,
                          accentColor: Colors.orange,
                          onTapDown: () =>
                              setState(() => _buttonPressed = true),
                          onTapUp: () =>
                              setState(() => _buttonPressed = false),
                          onTap: _capturing ? null : _capture,
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
  final bool capturing;
  final bool pressed;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;

  const _ShutterButton({
    required this.capturing,
    required this.pressed,
    required this.accentColor,
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
            border: Border.all(color: accentColor, width: 3.5),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: pressed ? 52 : 60,
              height: pressed ? 52 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: capturing
                    ? accentColor.withValues(alpha: 0.5)
                    : accentColor,
              ),
              child: capturing
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final boxSize = size.width * 0.5;

    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: boxSize, height: boxSize);
    final dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, rect.top), dimPaint);
    canvas.drawRect(Rect.fromLTWH(0, rect.bottom, size.width,
        size.height - rect.bottom), dimPaint);
    canvas.drawRect(
        Rect.fromLTWH(0, rect.top, rect.left, boxSize), dimPaint);
    canvas.drawRect(Rect.fromLTWH(rect.right, rect.top,
        size.width - rect.right, boxSize), dimPaint);

    // Rounded corner accents
    const len = 20.0;
    const radius = 4.0;
    final corner = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        rect.topLeft + const Offset(radius, 0),
        rect.topLeft + const Offset(len, 0), corner);
    canvas.drawLine(
        rect.topLeft + const Offset(0, radius),
        rect.topLeft + const Offset(0, len), corner);
    canvas.drawLine(
        rect.topRight + const Offset(-len, 0),
        rect.topRight + const Offset(-radius, 0), corner);
    canvas.drawLine(
        rect.topRight + const Offset(0, radius),
        rect.topRight + const Offset(0, len), corner);
    canvas.drawLine(
        rect.bottomLeft + const Offset(radius, 0),
        rect.bottomLeft + const Offset(len, 0), corner);
    canvas.drawLine(
        rect.bottomLeft + const Offset(0, -len),
        rect.bottomLeft + const Offset(0, -radius), corner);
    canvas.drawLine(
        rect.bottomRight + const Offset(-len, 0),
        rect.bottomRight + const Offset(-radius, 0), corner);
    canvas.drawLine(
        rect.bottomRight + const Offset(0, -len),
        rect.bottomRight + const Offset(0, -radius), corner);
  }

  @override
  bool shouldRepaint(_GuideOverlayPainter old) => false;
}
