import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum VersionCheckResult { upToDate, softUpdate, forceUpdate }

class VersionStatus {
  final VersionCheckResult result;
  final String latestVersion;
  const VersionStatus({required this.result, required this.latestVersion});
}

class VersionService {
  static const _baseUrl = 'https://mlharum.unitani.com';
  static const _appKey = 'ai_harumanis';
  static const apkUrl =
      'https://pub-09d17b214a8449658a27e1cbecccb5ab.r2.dev/Ai-Harumanis.apk';

  static Future<VersionStatus> check() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      final res = await Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      )).get('/version');

      final data = res.data[_appKey] as Map<String, dynamic>;
      final latest = data['latest'] as String;
      final minRequired = data['min_required'] as String;

      if (_isBelow(current, minRequired)) {
        return VersionStatus(result: VersionCheckResult.forceUpdate, latestVersion: latest);
      }
      if (_isBelow(current, latest)) {
        return VersionStatus(result: VersionCheckResult.softUpdate, latestVersion: latest);
      }
      return VersionStatus(result: VersionCheckResult.upToDate, latestVersion: latest);
    } catch (_) {
      // fail open — don't block the app if server is unreachable
      return const VersionStatus(result: VersionCheckResult.upToDate, latestVersion: '');
    }
  }

  static bool _isBelow(String current, String target) {
    final c = current.split('.').map(int.parse).toList();
    final t = target.split('.').map(int.parse).toList();
    for (var i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final tv = i < t.length ? t[i] : 0;
      if (cv < tv) return true;
      if (cv > tv) return false;
    }
    return false;
  }
}
