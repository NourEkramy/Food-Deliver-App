import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:food_delivery/features/auth/cubit/auth_state.dart';
import 'package:food_delivery/features/auth/view/login_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'auth_cubit_test.dart';

/// Pumps the login screen inside a minimal app.
///
/// [textScale] simulates a user who has increased the system font size, and
/// [locale] lets us check that a longer translation still fits. Both are how
/// layout overflows reach real users.
Future<AuthCubit> pumpLogin(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final cubit = AuthCubit(
    FakeAuthRepository(apiKey: 'test-key'),
    FakeSessionStorage(),
  );
  cubit.emit(const AuthState(status: AuthStatus.signedOut));

  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const LoginScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  group('layout', () {
    // A RenderFlex overflow throws during layout, so a clean pump is the
    // assertion. These caught two real overflows when the screen was written.
    testWidgets('fits a standard phone', (tester) async {
      await pumpLogin(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpLogin(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a 1.6x accessibility text scale', (tester) async {
      await pumpLogin(tester, textScale: 1.6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits in Arabic', (tester) async {
      await pumpLogin(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });
  });

  group('validation', () {
    testWidgets('blocks submission when the form is empty', (tester) async {
      final cubit = await pumpLogin(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      // No request should have been attempted.
      expect(cubit.state.isAuthenticated, isFalse);
    });

    testWidgets('rejects a malformed email', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.enterText(find.byType(TextFormField).last, 'secret123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('rejects a short password', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'nour@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('signs in when the form is valid', (tester) async {
      final cubit = await pumpLogin(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'nour@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'secret123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(cubit.state.isAuthenticated, isTrue);
      expect(cubit.state.apiKey, 'test-key');
    });
  });

  testWidgets('remember me is off by default and toggles on tap', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.text('Remember me'));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });
}
