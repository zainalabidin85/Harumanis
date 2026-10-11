import 'api_service.dart';
import 'auth_service.dart';

/// The user's own knuckle span (index to pinky knuckle, cm) — the reference
/// the server uses to turn pixels into fruit size. Lives on the account.
class HandSpanController {
  // Same bounds as the API (schemas.py). Outside this is a typo or wrong unit.
  static const minCm = 4.0;
  static const maxCm = 9.0;

  static final HandSpanController instance = HandSpanController(
    fetch: () async =>
        ((await ApiService.getMe())['knuckle_span_cm'] as num?)?.toDouble(),
    save: ApiService.updateKnuckleSpan,
    token: AuthService.getToken,
  );

  HandSpanController({
    required this.fetch,
    required Future<void> Function(double cm) save,
    required this.token,
  }) : _save = save;

  final Future<double?> Function() fetch;
  final Future<void> Function(double cm) _save;
  final Future<String?> Function() token;

  double? _cm;
  // The span belongs to an account, not the phone: a different login must not inherit it.
  String? _cmToken;

  /// Parses user input; null if it isn't a plausible span. Accepts "6,5".
  static double? parse(String input) {
    final value = double.tryParse(input.trim().replaceAll(',', '.'));
    if (value == null || value < minCm || value > maxCm) return null;
    return value;
  }

  /// The saved span, or null if the user hasn't measured (or it can't be read).
  Future<double?> current() async {
    final t = await token();
    if (_cm != null && _cmToken == t) return _cm;
    try {
      _cm = await fetch();
      _cmToken = t;
    } catch (_) {
      _cm = null;
    }
    return _cm;
  }

  /// Throws if the account could not be updated — scanning must not proceed on an unsaved span.
  Future<void> save(double cm) async {
    await _save(cm);
    _cm = cm;
    _cmToken = await token();
  }
}
