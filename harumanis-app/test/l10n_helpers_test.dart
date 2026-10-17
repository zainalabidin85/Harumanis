import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harumanis/l10n/l10n.dart';

void main() {
  final ms = lookupAppLocalizations(const Locale('ms'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('order statuses translate, unknown ones pass through', () {
    expect(orderStatusLabel(ms, 'delivered'), 'Dihantar');
    expect(orderStatusLabel(en, 'delivered'), 'Delivered');
    expect(orderStatusLabel(ms, 'refunded'), 'refunded');
  });

  test('pulp stage and confidence labels', () {
    expect(pulpStageLabel(ms, 4), 'Sedia dimakan');
    expect(pulpStageLabel(en, 4), 'Ready to eat');
    expect(pulpStageLabel(ms, 9), '');
    expect(pulpConfidenceLabel(ms, 'high'), 'tinggi');
    expect(pulpConfidenceLabel(ms, 'weird'), 'weird');
  });

  test('English plurals keep the wording used before translation', () {
    expect(en.marketFarmsAvailable(1), '1 farm available');
    expect(en.marketFarmsAvailable(3), '3 farms available');
    expect(en.marketReviewCount(1), '(1 review)');
    expect(en.pulpDaysToReady(1), 'Approx. 1 more day at room temperature');
    expect(en.pulpDaysToReady(2), 'Approx. 2 more days at room temperature');
  });
}
