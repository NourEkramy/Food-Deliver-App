import 'package:dio/dio.dart';
import 'package:food_delivery/core/network/api_config.dart';
import 'package:food_delivery/core/network/api_key_interceptor.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';

/// The authenticated HTTP client.
///
/// Same configuration as [ApiConfig.createDio], plus an interceptor that
/// attaches the logged-in user's API key to every outgoing request.
class ApiClient {
  final Dio dio;

  ApiClient(AuthCubit authCubit)
    : dio = ApiConfig.createDio()
        ..interceptors.add(ApiKeyInterceptor(authCubit));
}
