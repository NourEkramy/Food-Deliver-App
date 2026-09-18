import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/features/auth/view/login_screen.dart';
import 'core/network/api_client.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/repository/auth_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository(Dio())),
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          return RepositoryProvider(
            create: (context) => ApiClient(authCubit),
            child: MaterialApp(
              title: 'Food Delivery App',
              debugShowCheckedModeBanner: false,
              home: const LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}