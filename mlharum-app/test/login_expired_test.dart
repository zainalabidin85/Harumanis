import 'package:ai_harum/l10n/l10n.dart';
import 'package:ai_harum/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget home, String lang) => MaterialApp(
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

void main() {
  testWidgets('login screen explains an expired session', (tester) async {
    await tester.pumpWidget(app(const LoginScreen(sessionExpired: true), 'en'));
    await tester.pumpAndSettle();
    expect(find.text('Session expired. Please log in again.'), findsOneWidget);
  });

  testWidgets('the notice is in Malay for Malay users', (tester) async {
    await tester.pumpWidget(app(const LoginScreen(sessionExpired: true), 'ms'));
    await tester.pumpAndSettle();
    expect(find.text('Sesi tamat. Sila log masuk semula.'), findsOneWidget);
  });

  testWidgets('a normal login screen shows no notice', (tester) async {
    await tester.pumpWidget(app(const LoginScreen(), 'en'));
    await tester.pumpAndSettle();
    expect(find.text('Session expired. Please log in again.'), findsNothing);
  });
}
