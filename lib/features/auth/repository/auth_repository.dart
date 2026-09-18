import 'package:dio/dio.dart';

import '../model/auth_response.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await dio.get('/User/getusercode', queryParameters: {
        'UserEmail': email,
        'Password': password,
      });
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<AuthResponse> register(String email, String password) async {
    try {
      final response = await dio.post('/User/register', data: {
        'userEmail': email,
        'password': password,
      });
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Register failed: ${e.message}');
    }
  }
}