import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/locale/locale_cubit.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/onboarding/view/startup_gate.dart';
import 'features/address/cubit/address_cubit.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/payment/cubit/payment_cubit.dart';
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
  late final AddressCubit _addresses;
  late final PaymentCubit _payments;
  late final LocaleCubit _locale;

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

    // Addresses and cards are device-local and read from several screens, so
    // they are created once here like the cart.
    _addresses = AddressCubit()..load();
    _payments = PaymentCubit()..load();
    _locale = LocaleCubit()..load();
  }

  @override
  void dispose() {
    _locale.close();
    _payments.close();
    _addresses.close();
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
        BlocProvider.value(value: _addresses),
        BlocProvider.value(value: _payments),
        BlocProvider.value(value: _locale),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        // Signing out must not leave the next user holding someone else's cart.
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AuthStatus.signedOut,
        listener: (_, __) => _cart.clear(),
        child: RepositoryProvider.value(
          value: _apiClient,
          // Rebuilds the whole app when the language changes, so every screen
          // re-reads its strings and the text direction flips with it.
          child: BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,

              // Null follows the device setting, which is the default.
              locale: locale,

              // Translations. `localizationsDelegates` also pulls in Flutter's
              // own Material/Widgets/Cupertino translations, so built-in widgets
              // speak Arabic too — and RTL layout is applied automatically.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,

              // StartupGate shows onboarding on a first run, then hands over to
              // AuthGate, which decides between login and the app itself.
              home: const StartupGate(),
            ),
          ),
        ),
      ),
    );
  }
}
