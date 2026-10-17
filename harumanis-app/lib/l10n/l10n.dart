import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Growth stage number (1–3) to its display name.
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

/// Order status identifier from the API to its display name.
/// Unknown values are shown as received.
String orderStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'pending':
      return l10n.orderStatusPending;
    case 'confirmed':
      return l10n.orderStatusConfirmed;
    case 'harvested':
      return l10n.orderStatusHarvested;
    case 'delivered':
      return l10n.orderStatusDelivered;
    case 'cancelled':
      return l10n.orderStatusCancelled;
    default:
      return status;
  }
}

/// Pulp ripeness stage (1–5) to its display name.
String pulpStageLabel(AppLocalizations l10n, int stage) {
  switch (stage) {
    case 1:
      return l10n.pulpStage1;
    case 2:
      return l10n.pulpStage2;
    case 3:
      return l10n.pulpStage3;
    case 4:
      return l10n.pulpStage4;
    case 5:
      return l10n.pulpStage5;
    default:
      return '';
  }
}

/// Pulp confidence level from the API (high/medium/low). Unknown values are shown as received.
String pulpConfidenceLabel(AppLocalizations l10n, String level) {
  switch (level) {
    case 'high':
      return l10n.pulpConfidenceHigh;
    case 'medium':
      return l10n.pulpConfidenceMedium;
    case 'low':
      return l10n.pulpConfidenceLow;
    default:
      return level;
  }
}
