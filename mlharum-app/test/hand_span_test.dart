import 'package:ai_harum/l10n/l10n.dart';
import 'package:ai_harum/screens/hand_span_screen.dart';
import 'package:ai_harum/services/hand_span_service.dart';
import 'package:ai_harum/widgets/hand_span_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

HandSpanController make({
  double? onAccount,
  String token = 'token-a',
  String Function()? tokenFn,
  bool fetchFails = false,
  bool saveFails = false,
  List<double>? saved,
  List<int>? fetches,
}) {
  return HandSpanController(
    fetch: () async {
      fetches?.add(1);
      if (fetchFails) throw Exception('offline');
      return onAccount;
    },
    save: (cm) async {
      if (saveFails) throw Exception('offline');
      saved?.add(cm);
    },
    token: () async => tokenFn != null ? tokenFn() : token,
  );
}

Widget app(Widget home) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The demonstration loops forever; without this pumpAndSettle never settles.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: home,
    );

void main() {
  group('parse', () {
    test('accepts values inside the plausible range', () {
      expect(HandSpanController.parse('6.5'), 6.5);
      expect(HandSpanController.parse(' 4 '), 4.0);
      expect(HandSpanController.parse('9.0'), 9.0);
    });

    test('accepts a comma as the decimal separator', () {
      expect(HandSpanController.parse('6,5'), 6.5);
    });

    test('rejects empty, non-numeric and out-of-range input', () {
      for (final bad in ['', 'abc', '0', '3.9', '9.1', '65', '-6']) {
        expect(HandSpanController.parse(bad), isNull, reason: bad);
      }
    });
  });

  group('controller', () {
    test('reads the span saved on the account', () async {
      expect(await make(onAccount: 6.2).current(), 6.2);
    });

    test('is null when the account has no measurement', () async {
      expect(await make().current(), isNull);
    });

    test('is null when the account cannot be read', () async {
      expect(await make(onAccount: 6.2, fetchFails: true).current(), isNull);
    });

    test('remembers a known span without asking the server again', () async {
      final fetches = <int>[];
      final c = make(onAccount: 6.2, fetches: fetches);
      await c.current();
      await c.current();
      expect(fetches.length, 1);
    });

    test('does not reuse one account\'s span for another account', () async {
      var token = 'token-a';
      final fetches = <int>[];
      final c = make(onAccount: 6.2, tokenFn: () => token, fetches: fetches);
      await c.current();
      token = 'token-b';
      await c.current();
      expect(fetches.length, 2);
    });

    test('save stores to the account and is remembered', () async {
      final saved = <double>[];
      final fetches = <int>[];
      final c = make(saved: saved, fetches: fetches);
      await c.save(7.1);
      expect(saved, [7.1]);
      expect(await c.current(), 7.1);
      expect(fetches, isEmpty);
    });

    test('a failed save is not remembered', () async {
      final c = make(saveFails: true);
      await expectLater(c.save(7.1), throwsException);
      expect(await c.current(), isNull);
    });
  });

  group('screen', () {
    testWidgets('shows the measuring demonstration', (tester) async {
      await tester.pumpWidget(app(HandSpanScreen(controller: make())));
      expect(find.byType(HandSpanAnimation), findsOneWidget);
    });

    testWidgets('demonstration loops when animations are on', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SizedBox(width: 300, height: 200, child: HandSpanAnimation()),
      ));
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pump(const Duration(milliseconds: 3600));
      expect(tester.hasRunningAnimations, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects an implausible value without saving', (tester) async {
      final saved = <double>[];
      await tester.pumpWidget(app(HandSpanScreen(controller: make(saved: saved))));
      await tester.enterText(find.byType(TextField), '65');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, isEmpty);
      expect(find.text('Enter a value between 4 and 9 cm.'), findsOneWidget);
    });

    testWidgets('shows an error and stays open when saving fails', (tester) async {
      await tester.pumpWidget(app(HandSpanScreen(controller: make(saveFails: true))));
      await tester.enterText(find.byType(TextField), '6.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.byType(HandSpanScreen), findsOneWidget);
      expect(find.text('Could not save. Check your connection and try again.'), findsOneWidget);
    });
  });

  group('scan gate', () {
    Future<bool?> runGate(WidgetTester tester, HandSpanController c) async {
      bool? result;
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await ensureHandSpan(context, controller: c),
          child: const Text('scan'),
        ),
      )));
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      if (find.byType(HandSpanScreen).evaluate().isEmpty) return result;
      return null;
    }

    testWidgets('lets a measured user straight through', (tester) async {
      expect(await runGate(tester, make(onAccount: 6.2)), isTrue);
    });

    testWidgets('asks an unmeasured user and passes once saved', (tester) async {
      final saved = <double>[];
      bool? result;
      final c = make(saved: saved);
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await ensureHandSpan(context, controller: c),
          child: const Text('scan'),
        ),
      )));
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      expect(find.byType(HandSpanScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField), '6.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, [6.5]);
      expect(result, isTrue);
    });

    testWidgets('blocks the scan when the user backs out', (tester) async {
      bool? result;
      final c = make();
      await tester.pumpWidget(app(Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await ensureHandSpan(context, controller: c),
          child: const Text('scan'),
        ),
      )));
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });
}
