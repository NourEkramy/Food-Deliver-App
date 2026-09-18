import 'package:dio/dio.dart';
import '../../features/auth/cubit/auth_cubit.dart';

class ApiKeyInterceptor extends Interceptor {
  final AuthCubit authCubit;

  ApiKeyInterceptor(this.authCubit);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final state = authCubit.state;
    if (state.isAuthenticated) {
      options.queryParameters['apikey'] = state.apiKey;
    }
    handler.next(options);
  }
}