import 'package:dio/dio.dart';

/// Single source of truth for how we talk to the backend.
///
/// Both the authenticated client ([ApiClient]) and the plain client used for
/// login/register are built from here, so the base URL and timeouts can never
/// drift apart between them.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://fakerestaurantapi.runasp.net/api';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  /// A Dio pointed at the API with no authentication attached.
  ///
  /// This is what the auth endpoints need: you are asking the server *for* an
  /// API key, so you cannot be sending one yet.
  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ),
    );
  }
}
