import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/network/api_log_interceptor.dart';

/// Captures everything the interceptor prints during [action].
List<String> captureLogs(void Function() action) {
  final lines = <String>[];
  final original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) lines.add(message);
  };
  try {
    action();
  } finally {
    debugPrint = original;
  }
  return lines;
}

void main() {
  final interceptor = ApiLogInterceptor();

  test('never prints a password from the query string', () {
    final options = RequestOptions(
      path: '/User/getusercode',
      method: 'GET',
      queryParameters: {
        'UserEmail': 'nour@example.com',
        'Password': 'hunter2-secret',
      },
    );

    final logs = captureLogs(
      () => interceptor.onRequest(options, RequestInterceptorHandler()),
    );

    final all = logs.join('\n');
    expect(all, contains('/User/getusercode'));
    expect(all, contains('nour@example.com'), reason: 'email is fine to log');
    expect(all, isNot(contains('hunter2-secret')));
    expect(all, contains('***'));
  });

  test('never prints a password from the request body', () {
    final options = RequestOptions(
      path: '/User/register',
      method: 'POST',
      data: {'userEmail': 'nour@example.com', 'password': 'hunter2-secret'},
    );

    final logs = captureLogs(
      () => interceptor.onRequest(options, RequestInterceptorHandler()),
    );

    expect(logs.join('\n'), isNot(contains('hunter2-secret')));
  });

  test('never prints the API key returned by the server', () {
    final response = Response(
      requestOptions: RequestOptions(path: '/User/getusercode'),
      statusCode: 200,
      data: {'userEmail': 'nour@example.com', 'usercode': 'SECRET-KEY-123'},
    );

    final logs = captureLogs(
      () => interceptor.onResponse(response, ResponseInterceptorHandler()),
    );

    final all = logs.join('\n');
    expect(all, isNot(contains('SECRET-KEY-123')));
    // The key *names* still show, so you can see the shape came back correctly.
    expect(all, contains('usercode'));
  });

  test('summarises a list response by length rather than dumping it', () {
    final response = Response(
      requestOptions: RequestOptions(path: '/Restaurant'),
      statusCode: 200,
      data: List.generate(30, (i) => {'restaurantID': i}),
    );

    final logs = captureLogs(
      () => interceptor.onResponse(response, ResponseInterceptorHandler()),
    );

    expect(logs.join('\n'), contains('[30 items]'));
  });
}
