import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  static const _baseUrl = 'https://mlharum.unitani.com';

  static Dio _dio() => Dio(BaseOptions(baseUrl: _baseUrl, connectTimeout: const Duration(seconds: 15)));

  static Future<Dio> _authDio() async {
    final token = await AuthService.getToken();
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      headers: {'Authorization': 'Bearer $token'},
    ));
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  static Future<String> login(String email, String password) async {
    final res = await _dio().post('/auth/login', data: {'email': email, 'password': password});
    return res.data['access_token'] as String;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final dio = await _authDio();
    final res = await dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  // ── Admin stats ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getStats() async {
    final dio = await _authDio();
    final res = await dio.get('/admin/stats');
    return res.data as Map<String, dynamic>;
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getUsers({String? role, bool? isSuspended}) async {
    final dio = await _authDio();
    final Map<String, dynamic> params = {};
    if (role != null) params['role'] = role;
    if (isSuspended != null) params['is_suspended'] = isSuspended;
    final res = await dio.get('/admin/users', queryParameters: params);
    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateUser(int userId, {String? role, bool? isSuspended, bool? isVerified}) async {
    final dio = await _authDio();
    final Map<String, dynamic> data = {};
    if (role != null) data['role'] = role;
    if (isSuspended != null) data['is_suspended'] = isSuspended;
    if (isVerified != null) data['is_verified'] = isVerified;
    final res = await dio.patch('/admin/users/$userId', data: data);
    return res.data as Map<String, dynamic>;
  }

  // ── Farms ──────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getFarms({bool? isPublic}) async {
    final dio = await _authDio();
    final Map<String, dynamic> params = {};
    if (isPublic != null) params['is_public'] = isPublic;
    final res = await dio.get('/admin/farms', queryParameters: params);
    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateFarm(int farmId, {required bool isPublic}) async {
    final dio = await _authDio();
    final res = await dio.patch('/admin/farms/$farmId', data: {'is_public': isPublic});
    return res.data as Map<String, dynamic>;
  }

  // ── Orders ─────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getOrders({String? status, bool? paid}) async {
    final dio = await _authDio();
    final Map<String, dynamic> params = {};
    if (status != null) params['status'] = status;
    if (paid != null) params['paid'] = paid;
    final res = await dio.get('/admin/orders', queryParameters: params);
    return res.data as List<dynamic>;
  }

  // ── Payouts ────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getPayouts() async {
    final dio = await _authDio();
    final res = await dio.get('/admin/payouts');
    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> recordPayout(int orderId, String reference) async {
    final dio = await _authDio();
    final res = await dio.patch('/admin/payouts/$orderId', data: {'payout_reference': reference});
    return res.data as Map<String, dynamic>;
  }

  static String payoutInvoiceUrl(int orderId) => '$_baseUrl/admin/payouts/$orderId/invoice';
}
