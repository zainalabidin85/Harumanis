import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../theme.dart';

class QrScreen extends StatefulWidget {
  final int farmId;
  final String farmName;
  final int initialReadyInDays;

  const QrScreen({
    super.key,
    required this.farmId,
    required this.farmName,
    this.initialReadyInDays = 4,
  });

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  late int _readyInDays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _readyInDays = widget.initialReadyInDays;
  }

  Future<void> _updateDays(int days) async {
    setState(() { _readyInDays = days; _saving = true; });
    try {
      await ApiService.updateFarm(widget.farmId, readyInDays: days);
    } catch (_) {} finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = 'https://mlharum.unitani.com/farm/${widget.farmId}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kGreenPrimary,
        appBar: AppBar(
          backgroundColor: kGreenPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text('Buyer QR Code',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                Text(
                  widget.farmName,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Show this to buyers when selling your Harumanis',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // ── QR code card ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x30000000),
                          blurRadius: 40,
                          offset: Offset(0, 12)),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: url,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0A2E17),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF166534),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: kGreenLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🥭', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Text(
                              'Scan with any camera',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kGreenPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Ready in days setting ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.alarm_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Days until ready to eat',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const Spacer(),
                        if (_saving)
                          const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        'Buyers will be reminded after this many days',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [3, 4, 5, 6].map((days) {
                          final selected = _readyInDays == days;
                          return GestureDetector(
                            onTap: () => _updateDays(days),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: selected
                                    ? null
                                    : Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.3),
                                        width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$days',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? kGreenPrimary
                                            : Colors.white),
                                  ),
                                  Text(
                                    'days',
                                    style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        color: selected
                                            ? kGreenPrimary
                                            : Colors.white
                                                .withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── How it works ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How it works',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      _Step(
                          number: '1',
                          text: 'Buyer scans this QR with their phone camera'),
                      _Step(
                          number: '2',
                          text:
                              'A page opens — they tap "Open in Beli Harumanis" or download the app first'),
                      _Step(
                          number: '3',
                          text:
                              'They tap "Remind Me" → app notifies them in $_readyInDays days when fruit is ready to eat'),
                      _Step(
                          number: '4',
                          text:
                              'They can also place future orders directly from your farm page'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Tip: Take a screenshot and print this to display at your stall',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.65),
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85))),
          ),
        ],
      ),
    );
  }
}
