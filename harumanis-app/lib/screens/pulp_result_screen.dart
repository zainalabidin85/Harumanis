import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme.dart';

const _stageLabels = [
  '', 'Just harvested', 'Starting to ripen',
  'Ripening', 'Ready to eat', 'Overripe',
];

class PulpResultScreen extends StatefulWidget {
  final String imagePath;
  const PulpResultScreen({super.key, required this.imagePath});

  @override
  State<PulpResultScreen> createState() => _PulpResultScreenState();
}

class _PulpResultScreenState extends State<PulpResultScreen> {
  PulpAnalysisResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await ApiService.analyzePulp(widget.imagePath);
      setState(() => _result = result);
    } catch (e) {
      final msg = e.toString();
      setState(() {
        _error = msg.contains('SocketException') ||
                msg.contains('Connection refused')
            ? 'Cannot reach server. Check your connection.'
            : 'Analysis failed. Try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _rgbToColor(Map<String, int> rgb) =>
      Color.fromRGBO(rgb['r']!, rgb['g']!, rgb['b']!, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Pulp Analysis'),
        backgroundColor: kAmberDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: kAmberPrimary),
                  const SizedBox(height: 16),
                  Text('Analysing pulp colour…',
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 14)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.error_outline_rounded,
                              color: kRed, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: kText2, fontSize: 14)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _analyze,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kAmberPrimary,
                              minimumSize: const Size(140, 46)),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildResult(_result!),
    );
  }

  Widget _buildResult(PulpAnalysisResult r) {
    final detectedColor = _rgbToColor(r.detectedRgb);
    final referenceColor = _rgbToColor(r.referenceRgb);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Captured image ───────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: SizedBox(
              height: 220,
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Stage bar ────────────────────────────────────────
                _SectionLabel('Ripeness Stage'),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < r.stage;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300 + i * 80),
                        curve: Curves.easeOut,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: filled
                              ? kAmberPrimary
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stage ${r.stage} of 5 — ${_stageLabels[r.stage]}',
                  style: GoogleFonts.poppins(color: kText2, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // ── Metrics ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Brix (Sweetness)',
                        value: r.brixEstimate.toStringAsFixed(1),
                        unit: '°Bx',
                        color: kAmberPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Firmness',
                        value: r.firmnessEstimate.toStringAsFixed(1),
                        unit: 'N',
                        color: kAmberDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Ready status ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: r.isReady
                        ? const Color(0xFFF0FDF4)
                        : kAmberTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: r.isReady
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: r.isReady ? kGreen : kAmberPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          r.isReady
                              ? Icons.check_rounded
                              : Icons.hourglass_bottom_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.isReady ? 'Ready to eat' : 'Not ready yet',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: r.isReady ? kGreen : kAmberPrimary,
                              ),
                            ),
                            if (!r.isReady)
                              Text(
                                'Approx. ${r.daysToReady} more day${r.daysToReady == 1 ? '' : 's'} at room temperature',
                                style: GoogleFonts.poppins(
                                    color: kText2, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Colour comparison ────────────────────────────────
                _SectionLabel('Pulp Colour Comparison'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ColorSwatch(
                        label: 'Detected',
                        color: detectedColor,
                        rgb: r.detectedRgb,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ColorSwatch(
                        label: 'Stage ${r.stage} reference',
                        color: referenceColor,
                        rgb: r.referenceRgb,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${r.confidence}',
                  style: GoogleFonts.poppins(color: kText3, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on Nasir et al. (2021) — Harumanis ripeness guide (UniMAP)',
                  style: GoogleFonts.poppins(color: kText3, fontSize: 11),
                ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Scan Another Mango'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kAmberPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 14, color: kText1),
      );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final Map<String, int> rgb;

  const _ColorSwatch(
      {required this.label, required this.color, required this.rgb});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: kCardShadow,
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kText1)),
          Text(
            'R ${rgb['r']}  G ${rgb['g']}  B ${rgb['b']}',
            style: GoogleFonts.poppins(fontSize: 11, color: kText3),
          ),
        ],
      );
}
