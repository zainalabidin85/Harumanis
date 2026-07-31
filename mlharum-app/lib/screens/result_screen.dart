import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/fruit.dart';
import '../services/api_service.dart';
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
                child: _BboxImageView(imagePath: imagePath!, fruit: fruit, result: result),
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            children: [
              _FruitDetailCard(fruit: fruit),
              const SizedBox(height: 14),
              _FlushColorSection(fruit: fruit),
            ],
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

// ── Flush color section ───────────────────────────────────────────────────────
// Wraps the picker with its save-to-API state. Shown on both the "ready for
// bagging" and "recorded but past bagging window" result views — a late-bagged
// fruit still gets a physical color tag, so the farmer still needs to set it.
class _FlushColorSection extends StatefulWidget {
  final FruitResult fruit;
  const _FlushColorSection({required this.fruit});

  @override
  State<_FlushColorSection> createState() => _FlushColorSectionState();
}

class _FlushColorSectionState extends State<_FlushColorSection> {
  String? _selectedColor;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.fruit.flushColor;
  }

  Future<void> _pickColor(String color) async {
    setState(() {
      _selectedColor = color;
      _saving = true;
    });
    try {
      await ApiService.setFruitFlushColor(widget.fruit.id, color);
    } catch (_) {
      // Non-critical — farmer can still bag the fruit even if tagging fails.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FlushColorPicker(
      selected: _selectedColor,
      saving: _saving,
      onPick: _pickColor,
    );
  }
}

// ── Flush color picker ────────────────────────────────────────────────────────
// Lets the farmer tag this fruit with the same color they tie on the bagging
// paper for this blooming flush — an easier visual cue in the field than the
// numeric label. Purely additive; the numeric label remains the source of
// truth for yield counting.
class _FlushColorPicker extends StatelessWidget {
  static const colors = {
    'red': Color(0xFFEF4444),
    'yellow': Color(0xFFF59E0B),
    'blue': Color(0xFF0369A1),
    'green': Color(0xFF16A34A),
    'orange': Color(0xFFEA580C),
    'purple': Color(0xFF7C3AED),
  };

  final String? selected;
  final bool saving;
  final ValueChanged<String> onPick;
  const _FlushColorPicker({
    required this.selected,
    required this.saving,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tag bagging color (optional)',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 14, color: kText1),
          ),
          const SizedBox(height: 4),
          Text(
            'Match the color you tie on the bagging paper for this flush',
            style: GoogleFonts.poppins(fontSize: 12, color: kText2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: colors.entries.map((entry) {
              final isSelected = selected == entry.key;
              return GestureDetector(
                onTap: saving ? null : () {
                  HapticFeedback.lightImpact();
                  onPick(entry.key);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: kText1, width: 2.5)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
                child: _BboxImageView(imagePath: imagePath!, fruit: fruit, result: result),
              ),
            ),
          ),
        ],
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            children: [
              _FruitDetailCard(fruit: fruit),
              const SizedBox(height: 14),
              _FlushColorSection(fruit: fruit),
            ],
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
                child: _BboxImageView(imagePath: imagePath!, fruit: null, result: result),
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
  final FruitResult? fruit;
  final DetectionResponse result;
  const _BboxImageView({required this.imagePath, required this.fruit, required this.result});

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
            painter: _BboxPainter(
              fruit: widget.fruit,
              result: widget.result,
              imageSize: _imageSize!,
            ),
          ),
      ],
    );
  }
}

class _BboxPainter extends CustomPainter {
  final FruitResult? fruit;
  final DetectionResponse result;
  final Size imageSize;
  _BboxPainter({required this.fruit, required this.result, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    // BoxFit.cover scale: fill the widget, crop edges
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    final scale = max(scaleX, scaleY);
    final offsetX = (size.width - imageSize.width * scale) / 2;
    final offsetY = (size.height - imageSize.height * scale) / 2;
    Offset toCanvas(double x, double y) =>
        Offset(offsetX + x * scale, offsetY + y * scale);

    final fruit = this.fruit;
    if (fruit != null) {
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

    // Hand knuckle reference markers (index & pinky MCP joints used for scale)
    final ix = result.handIndexX;
    final iy = result.handIndexY;
    final px = result.handPinkyX;
    final py = result.handPinkyY;
    if (ix != null && iy != null && px != null && py != null) {
      final indexPt = toCanvas(ix, iy);
      final pinkyPt = toCanvas(px, py);

      canvas.drawLine(
        indexPt,
        pinkyPt,
        Paint()
          ..color = Colors.amberAccent
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );

      final dotPaint = Paint()..color = Colors.amberAccent;
      canvas.drawCircle(indexPt, 5, dotPaint);
      canvas.drawCircle(pinkyPt, 5, dotPaint);
    }
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
