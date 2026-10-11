import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Keeps the login alive while the app is in use, and ends it cleanly when
/// the server no longer accepts the token.
class SessionController {
  static final SessionController instance = SessionController(
    token: AuthService.getToken,
    renewToken: ApiService.refreshToken,
    saveToken: AuthService.saveToken,
    clear: AuthService.logout,
  );

  SessionController({
    required this.token,
    required this.renewToken,
    required Future<void> Function(String token) saveToken,
    required this.clear,
  }) : _saveToken = saveToken;

  final Future<String?> Function() token;
  final Future<String> Function() renewToken;
  final Future<void> Function(String token) _saveToken;
  final Future<void> Function() clear;

  /// Set by the app shell: take the user to the login screen.
  VoidCallback? onExpired;

  bool _expired = false;

  Future<void> saveToken(String token) async {
    await _saveToken(token);
    _expired = false;
  }

  /// Swaps the stored token for a fresh full-length one. Called on app open.
  /// Must never block or fail startup — offline or an older server just means
  /// the current token keeps being used.
  Future<void> renew() async {
    try {
      if (await token() == null) return;
      await saveToken(await renewToken());
    } catch (_) {}
  }

  /// The server rejected the token. Screens fire several requests at once, so
  /// only the first rejection acts.
  Future<void> expired() async {
    if (_expired) return;
    _expired = true;
    try {
      await clear();
    } catch (_) {}
    onExpired?.call();
  }

  /// For authenticated requests only — a 401 from /auth/login is a wrong password.
  late final Interceptor interceptor = InterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) await expired();
      handler.next(error);
    },
  );
}
