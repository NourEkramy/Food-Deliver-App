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
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_readableError(e, fallback: 'Login failed'));
    }
  }

  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await dio.post(
        '/User/register',
        data: {'userEmail': email, 'password': password},
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_readableError(e, fallback: 'Register failed'));
    }
  }

  /// Turns a [DioException] into something worth showing a user.
  ///
  /// The API answers a bad login with `{"message": "Invalid Details"}`, which is
  /// far more useful than Dio's own "status code of 404". We prefer the
  /// server's message, and fall back to a plain sentence when the request never
  /// reached the server at all.
  String _readableError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
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
