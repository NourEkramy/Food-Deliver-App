import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:food_delivery/features/auth/cubit/auth_state.dart';
import 'package:food_delivery/features/auth/view/register_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'auth_cubit_test.dart';

typedef Harness = ({AuthCubit cubit, FakeSessionStorage storage});

Future<Harness> pumpRegister(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final storage = FakeSessionStorage();
  final cubit = AuthCubit(FakeAuthRepository(apiKey: 'new-key'), storage);
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
          child: const RegisterScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (cubit: cubit, storage: storage);
}

/// Fills all four fields. [confirm] defaults to matching [password].
Future<void> fillForm(
  WidgetTester tester, {
  String name = 'Nour',
  String email = 'nour@example.com',
  String password = 'secret123',
  String? confirm,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), password);
  await tester.enterText(fields.at(3), confirm ?? password);
}

void main() {
  group('layout', () {
    testWidgets('fits a standard phone', (tester) async {
      await pumpRegister(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpRegister(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a 1.6x accessibility text scale', (tester) async {
      await pumpRegister(tester, textScale: 1.6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits in Arabic', (tester) async {
      await pumpRegister(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows all four fields from the design', (tester) async {
      await pumpRegister(tester);

      expect(find.text('NAME'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('RE-TYPE PASSWORD'), findsOneWidget);
    });
  });

  group('validation', () {
    testWidgets('blocks an empty form', (tester) async {
      final h = await pumpRegister(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(h.cubit.state.isAuthenticated, isFalse);
    });

    testWidgets('blocks mismatched passwords before any request', (
      tester,
    ) async {
      final h = await pumpRegister(tester);
      await fillForm(tester, password: 'secret123', confirm: 'secret999');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(
        h.cubit.state.isAuthenticated,
        isFalse,
        reason: 'no request should have been sent',
      );
    });

    testWidgets('blocks a short password', (tester) async {
      await pumpRegister(tester);
      await fillForm(tester, password: '123', confirm: '123');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });

  group('successful registration', () {
    testWidgets('signs in and keeps the name', (tester) async {
      final h = await pumpRegister(tester);
      await fillForm(tester, name: 'Nour');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(h.cubit.state.isAuthenticated, isTrue);
      expect(h.cubit.state.name, 'Nour');
      expect(h.cubit.state.displayName, 'Nour');
    });

    testWidgets('persists the session without a Remember me checkbox', (
      tester,
    ) async {
      final h = await pumpRegister(tester);
      await fillForm(tester, name: 'Nour');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Registering implies staying signed in; the designed screen has no
      // checkbox to opt in with.
      expect(h.storage.saved?.apiKey, 'new-key');
      expect(h.storage.saved?.name, 'Nour');
    });

    testWidgets('confirms with a message rather than silently jumping', (
      tester,
    ) async {
      await pumpRegister(tester);
      await fillForm(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Account created. Welcome!'), findsOneWidget);
    });
  });

  test('displayName falls back to the email when no name was captured', () {
    const state = AuthState(
      status: AuthStatus.signedIn,
      apiKey: 'k',
      email: 'nour@example.com',
    );

    expect(state.displayName, 'nour');
  });
}
