import 'package:dio/dio.dart';
import 'package:food_delivery/core/network/api_key_interceptor.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';

class ApiClient{
  final Dio dio;

  ApiClient(AuthCubit authCubit)
      : dio = Dio(BaseOptions(
    baseUrl: 'https://fakerestaurantapi.runasp.net/api',
     connectTimeout: const Duration(seconds: 10),
     receiveTimeout: const Duration(seconds: 10),
  )) ..interceptors.add(ApiKeyInterceptor(authCubit));
}