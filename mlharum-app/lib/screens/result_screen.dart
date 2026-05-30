import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fruit.dart';
import '../theme.dart';
import '../widgets/harvest_badge.dart';

class ResultScreen extends StatelessWidget {
  final DetectionResponse result;
  final String? imagePath;
  const ResultScreen({super.key, required this.result, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Tree ${result.treeNumber}'),
        automaticallyImplyLeading: false,
      ),
      body: result.readyForBagging
          ? _ReadyView(result: result, imagePath: imagePath)
          : _NotReadyView(result: result, imagePath: imagePath),
    );
  }
}

// ── Ready for bagging ─────────────────────────────────────────────────────────
class _ReadyView extends StatelessWidget {
  final DetectionResponse result;
  final String? imagePath;
  const _ReadyView({required this.result, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final fruit = result.fruits.first;
    return Column(
      children: [
        // Banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: kGreenPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kGreenPrimary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🥭', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for bagging',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Attach label ${fruit.label} to this fruit',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Image with bbox overlay
        if (imagePath != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _BboxImageView(imagePath: imagePath!, fruit: fruit),
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            children: [_FruitDetailCard(fruit: fruit)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              final nav = Navigator.of(context);
              nav.pop();
              nav.pop();
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

// ── Not ready ─────────────────────────────────────────────────────────────────
class _NotReadyView extends StatelessWidget {
  final DetectionResponse result;
  final String? imagePath;
  const _NotReadyView({required this.result, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final hasFruit = result.fruits.isNotEmpty;
    return hasFruit
        ? _RecordedView(result: result, imagePath: imagePath)
        : _StillDevelopingView(result: result, imagePath: imagePath);
  }
}

// Fruit recorded but bagging window has passed
class _RecordedView extends StatelessWidget {
  final DetectionResponse result;
  final String? imagePath;
  const _RecordedView({required this.result, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final fruit = result.fruits.first;
    return Column(
      children: [
        // Banner
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: kOrange,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kOrange.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🥭', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fruit Recorded',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      result.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Image with bbox overlay
        if (imagePath != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _BboxImageView(imagePath: imagePath!, fruit: fruit),
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            children: [_FruitDetailCard(fruit: fruit)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              final nav = Navigator.of(context);
              nav.pop();
              nav.pop();
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

// Fruit still developing — nothing recorded
class _StillDevelopingView extends StatelessWidget {
  final DetectionResponse result;
  final String? imagePath;
  const _StillDevelopingView({required this.result, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(File(imagePath!), fit: BoxFit.cover),
              ),
            ),
          ),
        ],
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: kOrange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.hourglass_bottom_rounded, size: 40, color: kOrange),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Still Developing',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kText1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    result.message,
                    style: GoogleFonts.poppins(fontSize: 14, color: kText2, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.pop();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Tree'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Image with bounding box overlay ──────────────────────────────────────────
class _BboxImageView extends StatefulWidget {
  final String imagePath;
  final FruitResult fruit;
  const _BboxImageView({required this.imagePath, required this.fruit});

  @override
  State<_BboxImageView> createState() => _BboxImageViewState();
}

class _BboxImageViewState extends State<_BboxImageView> {
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final bytes = await File(widget.imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _imageSize = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(widget.imagePath), fit: BoxFit.cover),
        if (_imageSize != null)
          CustomPaint(
            painter: _BboxPainter(fruit: widget.fruit, imageSize: _imageSize!),
          ),
      ],
    );
  }
}

class _BboxPainter extends CustomPainter {
  final FruitResult fruit;
  final Size imageSize;
  _BboxPainter({required this.fruit, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    // BoxFit.cover scale: fill the widget, crop edges
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    final scale = max(scaleX, scaleY);
    final offsetX = (size.width - imageSize.width * scale) / 2;
    final offsetY = (size.height - imageSize.height * scale) / 2;

    final rect = Rect.fromLTWH(
      offsetX + fruit.bboxX * scale,
      offsetY + fruit.bboxY * scale,
      fruit.bboxW * scale,
      fruit.bboxH * scale,
    );

    // Bounding box
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Corner fill to make it pop
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.greenAccent.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );

    // Size label pill above the box
    final label = '${fruit.sizeCm.toStringAsFixed(1)} cm';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pillW = tp.width + 16;
    final pillH = tp.height + 8;
    final pillLeft = rect.left;
    final pillTop = max(0.0, rect.top - pillH - 4);

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillLeft, pillTop, pillW, pillH),
      const Radius.circular(6),
    );
    canvas.drawRRect(pillRect, Paint()..color = Colors.greenAccent);
    tp.paint(canvas, Offset(pillLeft + 8, pillTop + 4));
  }

  @override
  bool shouldRepaint(_BboxPainter old) => false;
}

// ── Fruit detail card ─────────────────────────────────────────────────────────
class _FruitDetailCard extends StatelessWidget {
  final FruitResult fruit;
  const _FruitDetailCard({required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 86,
            decoration: const BoxDecoration(
              color: kGreenMid,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          const SizedBox(width: 14),
          const Text('🥭', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.label,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15, color: kText1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${fruit.sizeCm.toStringAsFixed(1)} cm  ·  ${fruit.stageName}',
                    style: GoogleFonts.poppins(color: kText2, fontSize: 13),
                  ),
                  const SizedBox(height: 7),
                  HarvestBadge(
                    harvestDate: fruit.harvestDate,
                    daysToHarvest: fruit.daysToHarvest,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
