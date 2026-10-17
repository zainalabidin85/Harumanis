import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'auth_service.dart';

class LocaleController extends ChangeNotifier {
  static const supportedCodes = ['ms', 'en'];
  static const defaultCode = 'ms';

  static const _storage = FlutterSecureStorage();
  static const _key = 'language';

  static final LocaleController instance = LocaleController(
    read: () => _storage.read(key: _key),
    write: (code) => _storage.write(key: _key, value: code),
    sync: _saveToAccount,
  );

  LocaleController({
    required this.read,
    required this.write,
    required this.sync,
  });

  final Future<String?> Function() read;
  final Future<void> Function(String code) write;
  final Future<void> Function(String code) sync;

  String _code = defaultCode;

  String get code => _code;
  Locale get locale => Locale(_code);

  /// Call once before runApp. Anything unreadable or unsupported means Malay.
  Future<void> load() async {
    try {
      final saved = await read();
      _code = supportedCodes.contains(saved) ? saved! : defaultCode;
    } catch (_) {
      _code = defaultCode;
    }
  }

  Future<void> setLocale(String code) async {
    if (!supportedCodes.contains(code) || code == _code) return;
    _code = code;
    notifyListeners();
    try {
      await write(code);
    } catch (_) {}
    await syncToAccount();
  }

  /// Saves the language to the account so push notifications follow it.
  /// Must never block or fail login/startup — same rule as push registration.
  Future<void> syncToAccount() async {
    try {
      await sync(_code);
    } catch (_) {}
  }

  static Future<void> _saveToAccount(String code) async {
    if (!await AuthService.isLoggedIn()) return;
    await ApiService.updateLanguage(code);
  }
}
