import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../restaurant_list/cubit/restaurant_cubit.dart';
import '../../restaurant_list/repository/restaurant_repository.dart';
import '../../restaurant_list/view/restaurant_list_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';

/// Decides what the app shows at launch, and swaps it whenever auth changes.
///
/// This replaces the old `Navigator.pushReplacement` on login success. Letting
/// the state drive the screen means there is exactly one rule for "what does a
/// signed-in user see", instead of every screen having to remember to navigate.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Reads secure storage once, moving status out of `unknown`.
    context.read<AuthCubit>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      // Only rebuild when the *status* changes. Without this the gate would
      // also rebuild on every keystroke-driven state change during login.
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return switch (state.status) {
          AuthStatus.unknown => const _SplashLoader(),
          AuthStatus.signedOut => const LoginScreen(),
          AuthStatus.signedIn => BlocProvider(
            create: (context) => RestaurantCubit(
              RestaurantRepository(context.read<ApiClient>().dio),
            ),
            child: const RestaurantListScreen(),
          ),
        };
      },
    );
  }
}

/// Shown for the moment it takes to read the saved session from the Keystore.
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.dark,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
