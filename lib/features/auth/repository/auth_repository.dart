import 'package:dio/dio.dart';

import '../model/auth_response.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await dio.get(
        '/User/getusercode',
        queryParameters: {'UserEmail': email, 'Password': password},
      );

      final auth = AuthResponse.tryParse(response.data, fallbackEmail: email);
      if (auth == null) {
        throw Exception('Could not sign you in. Please check your details.');
      }
      return auth;
    } on DioException catch (e) {
      throw Exception(_readableError(e, fallback: 'Login failed'));
    }
  }

  Future<AuthResponse> register(String email, String password) async {
    final AuthResponse? auth;
    try {
      final response = await dio.post(
        '/User/register',
        data: {'userEmail': email, 'password': password},
      );
      auth = AuthResponse.tryParse(response.data, fallbackEmail: email);
    } on DioException catch (e) {
      throw Exception(_readableError(e, fallback: 'Register failed'));
    }

    if (auth != null) return auth;

    // The account was created but the response carried no user code, so fetch
    // it the way a returning user would. Deliberately outside the try above:
    // a failure here is a *login* failure and should say so.
    return login(email, password);
  }

  /// Turns a [DioException] into something worth showing a user.
  ///
  /// The API answers a bad login with `{"message": "Invalid Details"}` and a
  /// malformed registration with an ASP.NET validation object. Both are more
  /// useful than Dio's own "status code of 404".
  String _readableError(DioException e, {required String fallback}) {
    final data = e.response?.data;

    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;

      // ASP.NET shape: {"errors": {"Password": ["The Password field is ..."]}}
      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values
            .whereType<List>()
            .expand((list) => list)
            .whereType<String>()
            .firstOrNull;
        if (first != null) return first;
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'The server took too long to respond.',
      DioExceptionType.connectionError =>
        'No internet connection. Please check your network.',
      _ => fallback,
    };
  }
}
