import 'package:ai_harum/services/locale_service.dart';
import 'package:ai_harum/widgets/language_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping EN then BM switches the language', (tester) async {
    final controller = LocaleController(
      read: () async => null,
      write: (_) async {},
      sync: (_) async {},
    );
    await controller.load();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: LanguageToggle(controller: controller)),
    ));

    expect(controller.code, 'ms');

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(controller.code, 'en');

    await tester.tap(find.text('BM'));
    await tester.pumpAndSettle();
    expect(controller.code, 'ms');
  });
}
