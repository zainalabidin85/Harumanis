import 'package:ai_harum/services/locale_service.dart';
import 'package:flutter_test/flutter_test.dart';

LocaleController make({
  String? saved,
  bool readFails = false,
  bool writeFails = false,
  bool syncFails = false,
  List<String>? written,
  List<String>? synced,
}) {
  return LocaleController(
    read: () async {
      if (readFails) throw Exception('storage unavailable');
      return saved;
    },
    write: (code) async {
      if (writeFails) throw Exception('storage unavailable');
      written?.add(code);
    },
    sync: (code) async {
      if (syncFails) throw Exception('offline');
      synced?.add(code);
    },
  );
}

void main() {
  test('defaults to Malay when nothing is saved', () async {
    final c = make();
    await c.load();
    expect(c.code, 'ms');
    expect(c.locale.languageCode, 'ms');
  });

  test('loads a saved English choice', () async {
    final c = make(saved: 'en');
    await c.load();
    expect(c.code, 'en');
  });

  for (final bad in ['', 'fr', 'EN', 'ms-MY']) {
    test('falls back to Malay for corrupt saved value "$bad"', () async {
      final c = make(saved: bad);
      await c.load();
      expect(c.code, 'ms');
    });
  }

  test('falls back to Malay when storage cannot be read', () async {
    final c = make(readFails: true);
    await c.load();
    expect(c.code, 'ms');
  });

  test('setLocale changes the language, notifies, saves and syncs', () async {
    final written = <String>[];
    final synced = <String>[];
    final c = make(written: written, synced: synced);
    await c.load();
    var notified = 0;
    c.addListener(() => notified++);

    await c.setLocale('en');

    expect(c.code, 'en');
    expect(notified, 1);
    expect(written, ['en']);
    expect(synced, ['en']);
  });

  test('setLocale ignores unsupported codes', () async {
    final c = make();
    await c.load();
    var notified = 0;
    c.addListener(() => notified++);

    await c.setLocale('fr');

    expect(c.code, 'ms');
    expect(notified, 0);
  });

  test('setLocale to the current language does nothing', () async {
    final synced = <String>[];
    final c = make(synced: synced);
    await c.load();
    await c.setLocale('ms');
    expect(synced, isEmpty);
  });

  test('language still switches when saving and syncing fail', () async {
    final c = make(writeFails: true, syncFails: true);
    await c.load();
    await c.setLocale('en');
    expect(c.code, 'en');
  });

  test('syncToAccount swallows failures', () async {
    final c = make(syncFails: true);
    await c.load();
    await c.syncToAccount();
  });
}
