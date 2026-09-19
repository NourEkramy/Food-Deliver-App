import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:food_delivery/features/auth/cubit/auth_state.dart';
import 'package:food_delivery/features/restaurant_list/cubit/restaurant_cubit.dart';
import 'package:food_delivery/features/restaurant_list/model/restaurant.dart';
import 'package:food_delivery/features/restaurant_list/repository/restaurant_repository.dart';
import 'package:food_delivery/features/restaurant_list/view/restaurant_list_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'auth_cubit_test.dart';

class FakeRestaurantRepository extends RestaurantRepository {
  final List<Restaurant> restaurants;
  final String? failWith;

  FakeRestaurantRepository({this.restaurants = const [], this.failWith})
    : super(Dio());

  @override
  Future<List<Restaurant>> getAllRestaurants() async {
    if (failWith != null) throw Exception(failWith);
    return restaurants;
  }
}

const _sample = [
  Restaurant(
    restaurantID: 1,
    restaurantName: 'Paradise Biryani',
    address: 'Hyderabad, Secunderabad, Telangana',
    type: 'Biryani',
    parkingLot: true,
    imageUrl: 'https://example.test/a.jpg',
    dishCount: 3,
  ),
  Restaurant(
    restaurantID: 2,
    restaurantName: 'Britannia & Co.',
    address: 'Mumbai, Ballard, Maharashtra',
    type: 'Parsi Cuisine',
    parkingLot: false,
    imageUrl: 'https://example.test/b.jpg',
    dishCount: 1,
  ),
];

Future<void> pumpHome(
  WidgetTester tester, {
  List<Restaurant> restaurants = _sample,
  String? failWith,
  String name = 'Nour',
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final auth = AuthCubit(FakeAuthRepository(apiKey: 'k'), FakeSessionStorage());
  auth.emit(
    AuthState(
      status: AuthStatus.signedIn,
      apiKey: 'k',
      email: 'nour@example.com',
      name: name,
    ),
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider(
          create: (_) => RestaurantCubit(
            FakeRestaurantRepository(
              restaurants: restaurants,
              failWith: failWith,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const RestaurantListScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The vertical page scroller.
///
/// This screen has two Scrollables — the page and the horizontal category strip
/// — so `scrollUntilVisible` must be told which one, or it throws
/// "Bad state: Too many elements".
Finder get pageScroller => find.byType(Scrollable).first;

void main() {
  group('layout', () {
    testWidgets('fits a standard phone', (tester) async {
      await pumpHome(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone', (tester) async {
      await pumpHome(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a 1.6x accessibility text scale', (tester) async {
      await pumpHome(tester, textScale: 1.6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits in Arabic', (tester) async {
      await pumpHome(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });
  });

  group('content', () {
    testWidgets('greets the signed-in user by name', (tester) async {
      await pumpHome(tester, name: 'Nour');
      expect(find.text('Hey Nour, Good Afternoon!'), findsOneWidget);
    });

    testWidgets('shows only real facts on a card', (tester) async {
      await pumpHome(tester);

      expect(find.text('Paradise Biryani'), findsOneWidget);
      expect(find.text('Hyderabad'), findsOneWidget); // city, parsed
      expect(find.text('3 dishes'), findsOneWidget); // real count
      expect(find.text('Parking'), findsOneWidget); // real flag

      // The second card is below the fold and SliverList.builder is lazy, so
      // it does not exist until scrolled to.
      await tester.scrollUntilVisible(
        find.text('Britannia & Co.'),
        300,
        scrollable: pageScroller,
      );

      expect(find.text('Mumbai'), findsOneWidget);
      expect(find.text('No parking'), findsOneWidget);
    });

    testWidgets('pluralises the dish count correctly', (tester) async {
      await pumpHome(tester);

      expect(find.text('3 dishes'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('1 dish'),
        300,
        scrollable: pageScroller,
      );
      expect(find.text('1 dish'), findsOneWidget);
    });

    testWidgets('offers a chip per cuisine plus All', (tester) async {
      await pumpHome(tester);

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Biryani'), findsWidgets);
      expect(find.text('Parsi Cuisine'), findsWidgets);
    });

    testWidgets('shows a retry action when loading fails', (tester) async {
      await pumpHome(tester, failWith: 'No internet connection.');

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('filtering', () {
    testWidgets('search narrows the list by name', (tester) async {
      await pumpHome(tester);

      await tester.enterText(find.byType(TextField), 'paradise');
      await tester.pumpAndSettle();

      expect(find.text('Paradise Biryani'), findsOneWidget);
      expect(find.text('Britannia & Co.'), findsNothing);
    });

    testWidgets('search also matches city', (tester) async {
      await pumpHome(tester);

      await tester.enterText(find.byType(TextField), 'mumbai');
      await tester.pumpAndSettle();

      expect(find.text('Britannia & Co.'), findsOneWidget);
      expect(find.text('Paradise Biryani'), findsNothing);
    });

    testWidgets('reports when nothing matches', (tester) async {
      await pumpHome(tester);

      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.text('No restaurants here yet'), findsOneWidget);
    });

    testWidgets('tapping a category chip filters the list', (tester) async {
      await pumpHome(tester);

      // "Biryani" rather than "Parsi Cuisine": the chip strip scrolls
      // horizontally and the later chips start off-screen, so a tap on them
      // lands on nothing. `.first` is the chip — the card's type text for the
      // same cuisine appears later in the tree.
      await tester.tap(find.text('Biryani').first);
      await tester.pumpAndSettle();

      expect(find.text('Paradise Biryani'), findsOneWidget);
      expect(find.text('Britannia & Co.'), findsNothing);
    });
  });

  testWidgets('the drawer holds logout', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(find.text('Nour'), findsOneWidget);
    expect(find.text('nour@example.com'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
