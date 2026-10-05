// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageRowTitle => 'Language';

  @override
  String get languageMalay => 'Bahasa Malaysia';

  @override
  String get languageEnglish => 'English';

  @override
  String get stageEarly => 'Early';

  @override
  String get stageBagging => 'Bagging';

  @override
  String get stagePreHarvest => 'Pre-harvest';

  @override
  String get stageUnknown => 'Unknown';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String updateRequiredBody(String version) {
    return 'Ai-Harumanis v$version is required. Download the latest APK to continue.';
  }

  @override
  String updateAvailableBody(String version) {
    return 'Ai-Harumanis v$version is available with new features and fixes.';
  }

  @override
  String get updateLater => 'Later';

  @override
  String get updateExit => 'Exit';

  @override
  String get updateOk => 'OK';

  @override
  String get updateDownload => 'Download';
}
