// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get languageRowTitle => 'Bahasa';

  @override
  String get languageMalay => 'Bahasa Malaysia';

  @override
  String get languageEnglish => 'English';

  @override
  String get stageEarly => 'Awal';

  @override
  String get stageBagging => 'Pembalutan';

  @override
  String get stagePreHarvest => 'Pra-tuai';

  @override
  String get stageUnknown => 'Tidak diketahui';

  @override
  String get updateRequiredTitle => 'Kemas Kini Diperlukan';

  @override
  String get updateAvailableTitle => 'Kemas Kini Tersedia';

  @override
  String updateRequiredBody(String version) {
    return 'Ai-Harumanis v$version diperlukan. Muat turun APK terkini untuk meneruskan.';
  }

  @override
  String updateAvailableBody(String version) {
    return 'Ai-Harumanis v$version kini tersedia dengan ciri baharu dan pembaikan.';
  }

  @override
  String get updateLater => 'Nanti';

  @override
  String get updateExit => 'Keluar';

  @override
  String get updateOk => 'OK';

  @override
  String get updateDownload => 'Muat turun';
}
