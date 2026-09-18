import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../restaurant_list/cubit/restaurant_cubit.dart';
import '../../restaurant_list/repository/restaurant_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../restaurant_list/view/restaurant_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.isAuthenticated) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => RestaurantCubit(
                        RestaurantRepository(context.read<ApiClient>().dio),
                      ),
                      child: const RestaurantListScreen(),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  state.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().login(
                        emailController.text,
                        passwordController.text,
                      );
                    },
                    child: const Text('Log In'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}