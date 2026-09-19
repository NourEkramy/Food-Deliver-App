import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/features/auth/model/auth_response.dart';
import 'package:food_delivery/features/auth/repository/auth_repository.dart';

/// Answers requests from a lookup table instead of the network, so these tests
/// exercise the real Dio pipeline without touching the internet.
class StubAdapter implements HttpClientAdapter {
  /// path → (statusCode, json body)
  final Map<String, (int, Object)> routes;
  final List<String> calls = [];

  StubAdapter(this.routes);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options.path);
    final route = routes[options.path];
    if (route == null) {
      return ResponseBody.fromString('{}', 404);
    }
    final (status, body) = route;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthRepository repoWith(StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return AuthRepository(dio);
}

void main() {
  group('AuthResponse.tryParse', () {
    test('reads the usercode field', () {
      final r = AuthResponse.tryParse({
        'userEmail': 'nour@example.com',
        'usercode': 'KEY-1',
      });

      expect(r?.apiKey, 'KEY-1');
      expect(r?.userEmail, 'nour@example.com');
    });

    test('returns null when no code is present', () {
      expect(AuthResponse.tryParse({'message': 'Registered'}), isNull);
      expect(AuthResponse.tryParse({'usercode': ''}), isNull);
      expect(AuthResponse.tryParse('not a map'), isNull);
      expect(AuthResponse.tryParse(null), isNull);
    });

    test('falls back to the supplied email when the body omits it', () {
      final r = AuthResponse.tryParse({
        'usercode': 'KEY-1',
      }, fallbackEmail: 'nour@example.com');

      expect(r?.userEmail, 'nour@example.com');
    });
  });

  group('register', () {
    test('uses the code when the API returns one', () async {
      final adapter = StubAdapter({
        '/User/register': (200, {'userEmail': 'a@b.com', 'usercode': 'KEY-1'}),
      });

      final result = await repoWith(adapter).register('a@b.com', 'secret');

      expect(result.apiKey, 'KEY-1');
      expect(adapter.calls, [
        '/User/register',
      ], reason: 'no extra login needed');
    });

    test('logs in when the API acknowledges without a code', () async {
      final adapter = StubAdapter({
        '/User/register': (200, {'message': 'User registered successfully'}),
        '/User/getusercode': (
          200,
          {'userEmail': 'a@b.com', 'usercode': 'KEY-2'},
        ),
      });

      final result = await repoWith(adapter).register('a@b.com', 'secret');

      expect(result.apiKey, 'KEY-2');
      expect(adapter.calls, ['/User/register', '/User/getusercode']);
    });
  });

  group('error messages', () {
    test('prefers the API message', () async {
      final adapter = StubAdapter({
        '/User/getusercode': (404, {'message': 'Invalid Details'}),
      });

      expect(
        () => repoWith(adapter).login('a@b.com', 'wrong'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid Details'),
          ),
        ),
      );
    });

    test('unwraps an ASP.NET validation error', () async {
      final adapter = StubAdapter({
        '/User/register': (
          400,
          {
            'errors': {
              'UserEmail': [
                'The UserEmail field is not a valid e-mail address.',
              ],
            },
          },
        ),
      });

      expect(
        () => repoWith(adapter).register('bad', 'secret'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not a valid e-mail address'),
          ),
        ),
      );
    });
  });
}
