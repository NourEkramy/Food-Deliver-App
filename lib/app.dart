import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/orders/repository/order_repository.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _auth;
  late final ApiClient _apiClient;
  late final CartCubit _cart;

  @override
  void initState() {
    super.initState();

    // Built once here, in dependency order, rather than in nested providers:
    // auth depends on nothing, the API client needs auth for its key
    // interceptor, and the cart needs the API client to place orders.
    _auth = AuthCubit(
      // Auth uses a plain client: you cannot send an API key on the request
      // whose whole purpose is to go and fetch one.
      AuthRepository(ApiConfig.createDio()),
      const SecureSessionStorage(),
    );
    _apiClient = ApiClient(_auth);
    _cart = CartCubit(OrderRepository(_apiClient.dio));
  }

  @override
  void dispose() {
    _cart.close();
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _auth),
        // App-wide: the cart is reachable from the home header, the restaurant
        // screen and the item screen, and must survive navigation between them.
        BlocProvider.value(value: _cart),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        // Signing out must not leave the next user holding someone else's cart.
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.signedOut,
        listener: (_, __) => _cart.clear(),
        child: RepositoryProvider.value(
          value: _apiClient,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,

            // Translations. `localizationsDelegates` also pulls in Flutter's
            // own Material/Widgets/Cupertino translations, so built-in widgets
            // speak Arabic too — and RTL layout is applied automatically.
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            onGenerateTitle: (context) => AppLocalizations.of(context).appName,

            // AuthGate decides between the login screen and the app itself,
            // once it has checked storage for a remembered session.
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
