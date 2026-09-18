import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

/// Builds a bare app in [locale] that renders whatever [child] returns, with
/// the localizations available.
Widget _appIn(Locale locale, Widget Function(AppLocalizations l10n) child) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (context) => child(AppLocalizations.of(context))),
  );
}

void main() {
  testWidgets('resolves English strings', (tester) async {
    await tester.pumpWidget(
      _appIn(const Locale('en'), (l10n) => Text(l10n.openRestaurants)),
    );

    expect(find.text('Open Restaurants'), findsOneWidget);
  });

  testWidgets('resolves Arabic strings', (tester) async {
    await tester.pumpWidget(
      _appIn(const Locale('ar'), (l10n) => Text(l10n.openRestaurants)),
    );

    expect(find.text('المطاعم المفتوحة'), findsOneWidget);
  });

  testWidgets('greeting substitutes the name placeholder', (tester) async {
    await tester.pumpWidget(
      _appIn(const Locale('en'), (l10n) => Text(l10n.greeting('Nour'))),
    );

    expect(find.text('Hey Nour, Good Afternoon!'), findsOneWidget);
  });

  testWidgets('Arabic lays out right-to-left', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      _appIn(const Locale('ar'), (l10n) {
        return Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        );
      }),
    );

    expect(Directionality.of(captured), TextDirection.rtl);
  });

  test('both locales are registered', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      containsAll(<String>['en', 'ar']),
    );
  });
}
