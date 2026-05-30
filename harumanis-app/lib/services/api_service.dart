import 'package:dio/dio.dart';
import '../models/farm.dart';
import '../models/order.dart';
import '../models/testimonial.dart';
import 'auth_service.dart';

class PulpAnalysisResult {
  final int stage;
  final double brixEstimate;
  final double firmnessEstimate;
  final bool isReady;
  final int daysToReady;
  final Map<String, int> detectedRgb;
  final Map<String, int> referenceRgb;
  final String confidence;

  const PulpAnalysisResult({
    required this.stage,
    required this.brixEstimate,
    required this.firmnessEstimate,
    required this.isReady,
    required this.daysToReady,
    required this.detectedRgb,
    required this.referenceRgb,
    required this.confidence,
  });

  factory PulpAnalysisResult.fromJson(Map<String, dynamic> json) =>
      PulpAnalysisResult(
        stage: json['stage'] as int,
        brixEstimate: (json['brix_estimate'] as num).toDouble(),
        firmnessEstimate: (json['firmness_estimate'] as num).toDouble(),
        isReady: json['is_ready'] as bool,
        daysToReady: json['days_to_ready'] as int,
        detectedRgb: Map<String, int>.from(json['detected_rgb'] as Map),
        referenceRgb: Map<String, int>.from(json['reference_rgb'] as Map),
        confidence: json['confidence'] as String,
      );
}

class ApiService {
  static const _baseUrl = 'https://mlharum.unitani.com';

  static Dio _dio() => Dio(BaseOptions(baseUrl: _baseUrl));

  static Future<Dio> _authDio() async {
    final token = await AuthService.getToken();
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    ));
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<String> login(String email, String password) async {
    final res = await _dio().post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data['access_token'] as String;
  }

  static Future<void> register(
      String name, String email, String password, String address,
      {String? phone, String? whatsapp}) async {
    await _dio().post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      'role': 'buyer',
    });
  }

  static Future<void> forgotPassword(String email) async {
    await _dio().post('/auth/forgot-password', data: {'email': email});
  }

  static Future<void> resetPassword(
      String email, String otp, String newPassword) async {
    await _dio().post('/auth/reset-password', data: {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    });
  }

  // ── Marketplace ───────────────────────────────────────────────────────────

  static Future<List<FarmSummary>> getMarketplace() async {
    final dio = await _authDio();
    final res = await dio.get('/marketplace');
    return (res.data as List)
        .map((f) => FarmSummary.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  static Future<FarmDetail> getFarmDetail(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/marketplace/$farmId');
    return FarmDetail.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  static Future<Order> createOrder({
    required int farmId,
    required double quantityKg,
    DateTime? targetHarvestDate,
    String? notes,
  }) async {
    final dio = await _authDio();
    final res = await dio.post('/orders', data: {
      'farm_id': farmId,
      'quantity_kg': quantityKg,
      if (targetHarvestDate != null)
        'target_harvest_date':
            targetHarvestDate.toIso8601String().substring(0, 10),
      if (notes != null) 'notes': notes,
    });
    return Order.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<List<Order>> getMyOrders() async {
    final dio = await _authDio();
    final res = await dio.get('/orders/my');
    return (res.data as List)
        .map((o) => Order.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> initiatePayment(int orderId) async {
    final dio = await _authDio();
    final res = await dio.post('/orders/$orderId/pay');
    return res.data as Map<String, dynamic>;
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMe() async {
    final dio = await _authDio();
    final res = await dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  static Future<void> updateMe({
    String? name,
    String? address,
    String? phone,
    String? whatsapp,
  }) async {
    final dio = await _authDio();
    await dio.patch('/auth/me', data: {
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
    });
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  static Future<List<Testimonial>> getFarmReviews(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/farms/$farmId/reviews');
    return (res.data as List)
        .map((t) => Testimonial.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  static Future<Testimonial?> getMyReview(int farmId) async {
    try {
      final dio = await _authDio();
      final res = await dio.get('/farms/$farmId/reviews/mine');
      return Testimonial.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<Testimonial> submitReview(int farmId, int rating, String? comment) async {
    final dio = await _authDio();
    final res = await dio.post('/farms/$farmId/reviews', data: {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return Testimonial.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<Testimonial> updateReview(int farmId, int reviewId, int rating, String? comment) async {
    final dio = await _authDio();
    final res = await dio.patch('/farms/$farmId/reviews/$reviewId', data: {
      'rating': rating,
      'comment': comment,
    });
    return Testimonial.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> deleteReview(int farmId, int reviewId) async {
    final dio = await _authDio();
    await dio.delete('/farms/$farmId/reviews/$reviewId');
  }

  // ── Pulp Analysis ─────────────────────────────────────────────────────────

  static Future<PulpAnalysisResult> analyzePulp(String imagePath) async {
    final dio = await _authDio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'pulp.jpg'),
    });
    final res = await dio.post(
      '/analyze/pulp',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return PulpAnalysisResult.fromJson(res.data as Map<String, dynamic>);
  }
}
