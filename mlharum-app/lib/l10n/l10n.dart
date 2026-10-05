import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Growth stage number (1–3) to its display name. Models have no BuildContext,
/// so stage names are resolved here instead of on Fruit/ActiveFruit.
String stageName(AppLocalizations l10n, int stage) {
  switch (stage) {
    case 1:
      return l10n.stageEarly;
    case 2:
      return l10n.stageBagging;
    case 3:
      return l10n.stagePreHarvest;
    default:
      return l10n.stageUnknown;
  }
}
