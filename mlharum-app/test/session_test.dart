import 'dart:typed_data';

import 'package:ai_harum/services/session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

SessionController make({
  String? token = 'old',
  String renewed = 'new',
  bool renewFails = false,
  List<String>? saved,
  List<int>? cleared,
}) {
  var current = token;
  return SessionController(
    token: () async => current,
    renewToken: () async {
      if (renewFails) throw Exception('offline');
      return renewed;
    },
    saveToken: (t) async {
      current = t;
      saved?.add(t);
    },
    clear: () async {
      current = null;
      cleared?.add(1);
    },
  );
}

class _FixedStatusAdapter implements HttpClientAdapter {
  _FixedStatusAdapter(this.status);
  final int status;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('{}', status,
          headers: {Headers.contentTypeHeader: ['application/json']});

  @override
  void close({bool force = false}) {}
}

Dio dioAnswering(int status, SessionController c) => Dio(BaseOptions(baseUrl: 'https://example.test'))
  ..httpClientAdapter = _FixedStatusAdapter(status)
  ..interceptors.add(c.interceptor);

void main() {
  group('renew', () {
    test('stores the fresh token', () async {
      final saved = <String>[];
      await make(saved: saved).renew();
      expect(saved, ['new']);
    });

    test('does nothing when logged out', () async {
      final saved = <String>[];
      await make(token: null, saved: saved).renew();
      expect(saved, isEmpty);
    });

    test('keeps the current login when renewal fails', () async {
      final saved = <String>[];
      final cleared = <int>[];
      await make(renewFails: true, saved: saved, cleared: cleared).renew();
      expect(saved, isEmpty);
      expect(cleared, isEmpty);
    });
  });

  group('expired', () {
    test('clears the login and notifies', () async {
      final cleared = <int>[];
      var notified = 0;
      final c = make(cleared: cleared)..onExpired = () => notified++;
      await c.expired();
      expect(cleared.length, 1);
      expect(notified, 1);
    });

    test('several failing requests at once send the user to login only once', () async {
      var notified = 0;
      final c = make()..onExpired = () => notified++;
      await Future.wait([c.expired(), c.expired(), c.expired()]);
      expect(notified, 1);
    });

    test('a later expiry after logging in again is handled again', () async {
      var notified = 0;
      final c = make()..onExpired = () => notified++;
      await c.expired();
      await c.saveToken('fresh');
      await c.expired();
      expect(notified, 2);
    });
  });

  group('interceptor', () {
    test('a rejected token ends the session', () async {
      var notified = 0;
      final c = make()..onExpired = () => notified++;
      await expectLater(dioAnswering(401, c).get('/trees'), throwsA(isA<DioException>()));
      expect(notified, 1);
    });

    test('other errors leave the session alone', () async {
      var notified = 0;
      final c = make()..onExpired = () => notified++;
      await expectLater(dioAnswering(500, c).get('/trees'), throwsA(isA<DioException>()));
      await expectLater(dioAnswering(403, c).get('/trees'), throwsA(isA<DioException>()));
      expect(notified, 0);
    });
  });
}
