import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage  = FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<bool> isLoggedIn() async => (await getToken()) != null;

  // Not deleteAll(): the language choice is stored alongside and must survive logout.
  static Future<void> logout() => _storage.delete(key: _tokenKey);
}
