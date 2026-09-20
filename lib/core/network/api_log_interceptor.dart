import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints each request and response to the console in debug builds.
///
/// Deliberately hand-written rather than Dio's own [LogInterceptor]: that one
/// dumps the raw query string and request body, which on this API means
/// printing the user's **password in plain text** on every login. Everything
/// here is redacted by default and only named fields are shown.
class ApiLogInterceptor extends Interceptor {
  static const _redacted = '***';

  /// Query parameters and body fields whose values must never be printed.
  static const _secrets = {'password', 'apikey', 'usercode'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.path}${_query(options)}');
      final body = _safeBody(options.data);
      if (body != null) debugPrint('  body: $body');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.path} '
        '${_summarise(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ ${err.response?.statusCode ?? err.type.name} '
        '${err.requestOptions.path} ${_summarise(err.response?.data)}',
      );
    }
    handler.next(err);
  }

  String _query(RequestOptions options) {
    if (options.queryParameters.isEmpty) return '';
    final parts = options.queryParameters.entries.map(
      (e) => '${e.key}=${_isSecret(e.key) ? _redacted : e.value}',
    );
    return '?${parts.join('&')}';
  }

  String? _safeBody(Object? data) {
    if (data is! Map) return null;
    final safe = data.map(
      (key, value) =>
          MapEntry(key, _isSecret(key.toString()) ? _redacted : value),
    );
    return safe.toString();
  }

  /// Shows the shape of a response without dumping its contents.
  ///
  /// Lists report the keys of their first element as well as their length.
  /// Without that, a list response revealed nothing about the objects inside
  /// it — which is how the Order model came to be written against guessed
  /// field names.
  String _summarise(Object? data) {
    if (data is List) {
      final count = '[${data.length} items]';
      final first = data.firstOrNull;
      if (first is Map) return '$count first: ${_keys(first)}';
      return count;
    }
    if (data is Map) return _keys(data);
    return '';
  }

  String _keys(Map data) =>
      '{${data.keys.map((k) => k.toString()).join(', ')}}';

  bool _isSecret(String key) => _secrets.contains(key.toLowerCase());
}
