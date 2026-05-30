import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadService {
  static const _keyServerUrl = 'server_url';
  static const _keyTagger = 'tagger_name';

  static Future<String> getServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServerUrl) ?? '';
  }

  static Future<String> getTaggerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTagger) ?? '';
  }

  static Future<void> saveSettings(String serverUrl, String tagger) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, serverUrl.trim());
    await prefs.setString(_keyTagger, tagger.trim());
  }

  // Upload image with bounding box annotations — all boxes are class 0 (mango)
  static Future<Map<String, dynamic>> uploadAnnotated({
    required String imagePath,
    required List<Map<String, dynamic>> annotations,
    String notes = '',
  }) async {
    final serverUrl = await getServerUrl();
    if (serverUrl.isEmpty) throw Exception('Server URL not configured.');

    final tagger = await getTaggerName();

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'capture.jpg'),
      'annotations': jsonEncode(annotations),
      'tagger': tagger.isEmpty ? 'anonymous' : tagger,
      'notes': notes,
    });

    final dio = Dio(BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    final res = await dio.post(
      '/training/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getStats() async {
    final serverUrl = await getServerUrl();
    if (serverUrl.isEmpty) throw Exception('Server URL not configured.');
    final dio = Dio(BaseOptions(baseUrl: serverUrl));
    final res = await dio.get('/training/stats');
    return res.data as Map<String, dynamic>;
  }

  static Future<void> startTraining() async {
    final serverUrl = await getServerUrl();
    if (serverUrl.isEmpty) throw Exception('Server URL not configured.');
    final dio = Dio(BaseOptions(baseUrl: serverUrl, connectTimeout: const Duration(seconds: 10)));
    await dio.post('/training/train');
  }

  static Future<Map<String, dynamic>> getTrainingStatus() async {
    final serverUrl = await getServerUrl();
    if (serverUrl.isEmpty) throw Exception('Server URL not configured.');
    final dio = Dio(BaseOptions(baseUrl: serverUrl, connectTimeout: const Duration(seconds: 10)));
    final res = await dio.get('/training/train/status');
    return res.data as Map<String, dynamic>;
  }
}
