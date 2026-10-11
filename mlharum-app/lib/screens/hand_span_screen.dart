import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';
import '../services/hand_span_service.dart';
import '../theme.dart';
import '../widgets/hand_span_animation.dart';
import '../widgets/page_route.dart';

/// Returns true once the user has a saved hand measurement, asking for it if
/// they don't. Scanning is not allowed without one.
Future<bool> ensureHandSpan(
  BuildContext context, {
  HandSpanController? controller,
}) async {
  final c = controller ?? HandSpanController.instance;
  if (await c.current() != null) return true;
  if (!context.mounted) return false;
  final saved = await Navigator.push<bool>(
    context,
    FadeSlideRoute(page: HandSpanScreen(controller: c)),
  );
  return saved == true;
}

/// Asks for the user's knuckle span. Pops with `true` after a successful save.
class HandSpanScreen extends StatefulWidget {
  const HandSpanScreen({super.key, this.controller, this.initialCm});

  final HandSpanController? controller;
  final double? initialCm;

  @override
  State<HandSpanScreen> createState() => _HandSpanScreenState();
}

class _HandSpanScreenState extends State<HandSpanScreen> {
  late final _ctrl = TextEditingController(
    text: widget.initialCm?.toStringAsFixed(1) ?? '',
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    final l10n = context.l10n;
    final cm = HandSpanController.parse(_ctrl.text);
    if (cm == null) {
      setState(() => _error = l10n.handSpanErrorRange(
          _trim(HandSpanController.minCm), _trim(HandSpanController.maxCm)));
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await (widget.controller ?? HandSpanController.instance).save(cm);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = l10n.handSpanErrorSave; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: Text(l10n.handSpanTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: kCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 200, child: HandSpanAnimation()),
                    const SizedBox(height: 12),
                    Text(l10n.handSpanHow,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13, color: kText2)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: l10n.handSpanFieldLabel,
                  hintText: l10n.handSpanFieldHint,
                  errorText: _error,
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
