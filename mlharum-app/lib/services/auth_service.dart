import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _farmIdKey = 'farm_id';
  static const _roleKey = 'role';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> saveFarmId(int farmId) =>
      _storage.write(key: _farmIdKey, value: farmId.toString());

  static Future<int?> getFarmId() async {
    final value = await _storage.read(key: _farmIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);

  static Future<String?> getRole() => _storage.read(key: _roleKey);

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    // Not deleteAll(): the language choice is stored alongside and must survive logout.
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _farmIdKey);
    await _storage.delete(key: _roleKey);
  }
}
