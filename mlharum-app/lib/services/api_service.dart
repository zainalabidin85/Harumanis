import 'package:dio/dio.dart';
import '../models/tree.dart';
import '../models/fruit.dart';
import 'auth_service.dart';

class ApiService {
  static const _baseUrl = 'http://YOUR_SERVER_IP:8000';

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

  // ── Farms & Trees ───────────────────────────────────────────────────────────

  static Future<int> createFarm(String name, String location) async {
    final dio = await _authDio();
    final res = await dio.post('/farms', data: {
      'name': name,
      'location': location,
    });
    return res.data['id'];
  }

  static Future<List<Tree>> getTrees(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/farms/$farmId/trees');
    return (res.data as List).map((t) => Tree.fromJson(t)).toList();
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

  // ── Dashboard ───────────────────────────────────────────────────────────────

  static Future<FarmDashboard> getDashboard(int farmId) async {
    final dio = await _authDio();
    final res = await dio.get('/dashboard/$farmId');
    return FarmDashboard.fromJson(res.data);
  }
}
