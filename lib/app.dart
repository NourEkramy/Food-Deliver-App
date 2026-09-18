import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/view/auth_gate.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Auth uses a plain client: you cannot send an API key on the request
      // whose whole purpose is to go and fetch one.
      create: (_) => AuthCubit(
        AuthRepository(ApiConfig.createDio()),
        const SecureSessionStorage(),
      ),
      child: Builder(
        // This Builder exists so `context.read<AuthCubit>()` below can see the
        // BlocProvider above it — a context can only read providers declared by
        // its ancestors, never by itself.
        builder: (context) {
          return RepositoryProvider(
            // Every other feature uses this client, which attaches the signed-in
            // user's API key to each request via ApiKeyInterceptor.
            create: (_) => ApiClient(context.read<AuthCubit>()),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,

              // Translations. `localizationsDelegates` also pulls in Flutter's
              // own Material/Widgets/Cupertino translations, so built-in widgets
              // speak Arabic too — and RTL layout is applied automatically.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              // onGenerateTitle (rather than `title`) runs with a context that
              // has localizations available, so the task-switcher name is
              // translated as well.
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,

              // AuthGate decides between the login screen and the app itself,
              // once it has checked storage for a remembered session.
              home: const AuthGate(),
            ),
          );
        },
      ),
    );
  }
}
