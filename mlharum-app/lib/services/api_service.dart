import 'package:dio/dio.dart';
import '../models/tree.dart';
import '../models/fruit.dart';
import '../models/farm_order.dart';
import '../models/doa_report.dart';
import '../models/announcement.dart';
import 'auth_service.dart';

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

  // ── Auth ────────────────────────────────────────────────────────────────────

  static Future<String> login(String email, String password) async {
    final res = await _dio().post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data['access_token'];
  }

  static Future<void> register(String name, String email, String password, String? phone) async {
    await _dio().post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });
  }

  static Future<Map<String, dynamic>> getMe() async {
    final dio = await _authDio();
    final res = await dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateMe({
    String? name,
    String? phone,
    String? whatsapp,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
  }) async {
    final dio = await _authDio();
    final res = await dio.patch('/auth/me', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (bankName != null) 'bank_name': bankName,
      if (bankAccountNumber != null) 'bank_account_number': bankAccountNumber,
      if (bankAccountName != null) 'bank_account_name': bankAccountName,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<void> forgotPassword(String email) async {
    await _dio().post('/auth/forgot-password', data: {'email': email});
  }

  static Future<void> resetPassword(String email, String otp, String newPassword) async {
    await _dio().post('/auth/reset-password', data: {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    });
  }

  // ── Farms & Trees ───────────────────────────────────────────────────────────

  static Future<int> createFarm(String name, String location) async {
    final dio = await _authDio();
    final res = await dio.post('/farms', data: {
      'name': name,
      'location': location,
    });
    return res.data['id'];
  }

  static Future<Map<String, dynamic>> getFarm(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/farms/$farmId');
    return res.data as Map<String, dynamic>;
  }

  static Future<void> updateFarm(int farmId,
      {bool? isPublic, double? pricePerKg, String? name, String? location, int? readyInDays}) async {
    final dio = await _authDio();
    await dio.patch('/farms/$farmId', data: {
      if (isPublic != null) 'is_public': isPublic,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (readyInDays != null) 'ready_in_days': readyInDays,
    });
  }

  static Future<List<Tree>> getTrees(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/farms/$farmId/trees');
    return (res.data as List).map((t) => Tree.fromJson(t)).toList();
  }

  static Future<Tree> createTree(
    int farmId,
    String treeNumber, {
    String? notes,
    double? gpsLat,
    double? gpsLng,
  }) async {
    final dio = await _authDio();
    final res = await dio.post('/farms/$farmId/trees', data: {
      'trees': [
        {
          'tree_number': treeNumber,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (gpsLat != null) 'gps_lat': gpsLat,
          if (gpsLng != null) 'gps_lng': gpsLng,
        }
      ]
    });
    return Tree.fromJson((res.data as List).first);
  }

  static Future<void> deleteTree(int farmId, int treeId) async {
    final dio = await _authDio();
    await dio.delete('/farms/$farmId/trees/$treeId');
  }

  // ── Farm Images ─────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFarmImages(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/farms/$farmId/images');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  static Future<Map<String, dynamic>> uploadFarmImage(
      int farmId, String imagePath, String caption) async {
    final dio = await _authDio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'farm_photo.jpg'),
      'caption': caption,
    });
    final res = await dio.post(
      '/farms/$farmId/images',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<void> deleteFarmImage(int farmId, int imageId) async {
    final dio = await _authDio();
    await dio.delete('/farms/$farmId/images/$imageId');
  }

  // ── Orders (farmer) ─────────────────────────────────────────────────────────

  static Future<List<FarmOrder>> getFarmOrders(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/orders/farm/$farmId');
    return (res.data as List)
        .map((o) => FarmOrder.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  static Future<FarmOrder> updateOrderStatus(int orderId, String status) async {
    final dio = await _authDio();
    final res = await dio.patch('/orders/$orderId/status', data: {'status': status});
    return FarmOrder.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Detection ───────────────────────────────────────────────────────────────

  static Future<DetectionResponse> detectMangoes(int treeId, String imagePath) async {
    final dio = await _authDio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'capture.jpg'),
    });
    final res = await dio.post(
      '/detect/$treeId',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return DetectionResponse.fromJson(res.data);
  }

  // ── Fruit management ───────────────────────────────────────────────────────

  static Future<List<ActiveFruit>> getTreeFruits(int treeId) async {
    final dio = await _authDio();
    final res = await dio.get('/trees/$treeId/fruits');
    return (res.data as List).map((f) => ActiveFruit.fromJson(f)).toList();
  }

  static Future<ActiveFruit> harvestFruit(int fruitId) async {
    final dio = await _authDio();
    final res = await dio.patch('/trees/$fruitId/harvest');
    return ActiveFruit.fromJson(res.data);
  }

  static Future<ActiveFruit> abortFruit(int fruitId, {String? reason}) async {
    final dio = await _authDio();
    final res = await dio.patch('/trees/$fruitId/abort', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    return ActiveFruit.fromJson(res.data);
  }

  static Future<ActiveFruit> setFruitFlushColor(int fruitId, String color) async {
    final dio = await _authDio();
    final res = await dio.patch('/trees/$fruitId/flush-color', data: {
      'color': color,
    });
    return ActiveFruit.fromJson(res.data);
  }

  // ── Dashboard ───────────────────────────────────────────────────────────────

  static Future<FarmDashboard> getDashboard(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/dashboard/$farmId');
    return FarmDashboard.fromJson(res.data);
  }

  // ── Pulp Analysis ───────────────────────────────────────────────────────────

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

  // ── DOA ─────────────────────────────────────────────────────────────────────

  static Future<DoaYieldReport> getDoaYieldReport({int? season}) async {
    final dio = await _authDio();
    final res = await dio.get(
      '/doa/yield-report',
      queryParameters: season != null ? {'season': season} : null,
    );
    return DoaYieldReport.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> setOwnerVerified(int ownerId, bool isVerified) async {
    final dio = await _authDio();
    await dio.patch(
      '/doa/owners/$ownerId/verify',
      data: {'is_verified': isVerified},
    );
  }

  // ── Announcements ───────────────────────────────────────────────────────────

  static Future<List<Announcement>> getAnnouncements({bool upcoming = false}) async {
    final dio = await _authDio();
    final res = await dio.get('/announcements', queryParameters: {'upcoming': upcoming});
    return (res.data as List)
        .map((a) => Announcement.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  static Future<Announcement> getAnnouncement(int id) async {
    final dio = await _authDio();
    final res = await dio.get('/announcements/$id');
    return Announcement.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<Announcement> createAnnouncement({
    required String title,
    required String body,
    DateTime? eventDate,
    String? location,
    String? imagePath,
  }) async {
    final dio = await _authDio();
    final formData = FormData.fromMap({
      'title': title,
      'body': body,
      if (eventDate != null) 'event_date': eventDate.toIso8601String(),
      if (location != null && location.isNotEmpty) 'location': location,
      if (imagePath != null)
        'file': await MultipartFile.fromFile(imagePath, filename: 'announcement.jpg'),
    });
    final res = await dio.post(
      '/announcements',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Announcement.fromJson(res.data as Map<String, dynamic>);
  }

  static Future<void> deleteAnnouncement(int id) async {
    final dio = await _authDio();
    await dio.delete('/announcements/$id');
  }
}

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

  factory PulpAnalysisResult.fromJson(Map<String, dynamic> json) => PulpAnalysisResult(
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
