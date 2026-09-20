import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/locale/locale_cubit.dart';
import 'package:food_delivery/core/storage/local_store.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/core/widgets/language_picker.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'local_features_test.dart' show FakeLocalStore;

void main() {
  group('LocaleCubit', () {
    test('starts by following the device', () {
      expect(LocaleCubit(FakeLocalStore()).state, isNull);
    });

    test('remembers a chosen language', () async {
      final store = FakeLocalStore();
      await LocaleCubit(store).select(const Locale('ar'));

      final next = LocaleCubit(store);
      await next.load();

      expect(next.state?.languageCode, 'ar');
    });

    test('going back to the device setting clears the stored choice', () async {
      final store = FakeLocalStore();
      final cubit = LocaleCubit(store);
      await cubit.select(const Locale('ar'));

      await cubit.select(null);

      expect(cubit.state, isNull);
      expect(await store.readString(LocalStore.keyLocale), isNull);
    });
  });

  group('the picker', () {
    /// Pumps a screen with a button that opens the picker, plus a label showing
    /// the app's current language — so the effect of a choice is observable.
    Future<LocaleCubit> pumpPicker(WidgetTester tester) async {
      final cubit = LocaleCubit(FakeLocalStore());

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) => MaterialApp(
              locale: locale,
              theme: AppTheme.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context).openRestaurants),
                        TextButton(
                          onPressed: () => showLanguagePicker(context),
                          child: const Text('open'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return cubit;
    }

    testWidgets('offers the device default and both languages', (tester) async {
      await pumpPicker(tester);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('System default'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('choosing Arabic switches the whole app', (tester) async {
      final cubit = await pumpPicker(tester);
      expect(find.text('Open Restaurants'), findsOneWidget);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(cubit.state?.languageCode, 'ar');
      expect(find.text('المطاعم المفتوحة'), findsOneWidget);
      expect(find.text('Open Restaurants'), findsNothing);
    });

    testWidgets('switching to Arabic flips the layout direction', (
      tester,
    ) async {
      final cubit = await pumpPicker(tester);
      await cubit.select(const Locale('ar'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('المطاعم المفتوحة'));
      expect(Directionality.of(context), TextDirection.rtl);
    });

    testWidgets('language names are never translated', (tester) async {
      // Someone who cannot read the current language still has to recognise
      // their own, so both names stay in their own script in either locale.
      final cubit = await pumpPicker(tester);
      await cubit.select(const Locale('ar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    });
  });
}
