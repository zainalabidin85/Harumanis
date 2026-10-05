import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync()) as Map<String, dynamic>;

Iterable<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@'));

void main() {
  final en = _load('app_en.arb');
  final ms = _load('app_ms.arb');

  test('English and Malay have the same keys', () {
    expect(_messageKeys(ms).toSet(), _messageKeys(en).toSet());
  });

  test('no Malay value is empty', () {
    for (final key in _messageKeys(ms)) {
      expect((ms[key] as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('language row title is readable in either language', () {
    // Someone who cannot read the current language must still find the switch.
    expect(en['languageRowTitle'], 'Bahasa / Language');
    expect(ms['languageRowTitle'], 'Bahasa / Language');
  });

  test('Malay harvest badge spells out days so it is not read as hours', () {
    expect(ms['harvestBadgeLabel'], contains('hari'));
  });

  test('every placeholder declared in English is used in both languages', () {
    for (final key in _messageKeys(en)) {
      final meta = en['@$key'] as Map<String, dynamic>?;
      final placeholders = (meta?['placeholders'] as Map<String, dynamic>?)?.keys ?? const <String>[];
      for (final name in placeholders) {
        final pattern = RegExp('\\{$name[,}]');
        expect(pattern.hasMatch(en[key] as String), isTrue, reason: 'en $key missing {$name}');
        expect(pattern.hasMatch(ms[key] as String), isTrue, reason: 'ms $key missing {$name}');
      }
    }
  });
}
