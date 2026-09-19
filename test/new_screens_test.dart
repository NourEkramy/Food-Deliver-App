import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/features/cart/cubit/cart_cubit.dart';
import 'package:food_delivery/features/cart/view/cart_screen.dart';
import 'package:food_delivery/features/orders/cubit/orders_cubit.dart';
import 'package:food_delivery/features/orders/model/order.dart';
import 'package:food_delivery/features/orders/view/orders_screen.dart';
import 'package:food_delivery/features/restaurant_detail/cubit/restaurant_detail_cubit.dart';
import 'package:food_delivery/features/restaurant_detail/model/menu_item.dart';
import 'package:food_delivery/features/restaurant_detail/repository/restaurant_detail_repository.dart';
import 'package:food_delivery/features/restaurant_detail/view/food_details_screen.dart';
import 'package:food_delivery/features/restaurant_detail/view/restaurant_detail_screen.dart';
import 'package:food_delivery/features/restaurant_list/model/restaurant.dart';
import 'package:food_delivery/features/search/cubit/search_cubit.dart';
import 'package:food_delivery/features/search/repository/search_repository.dart';
import 'package:food_delivery/features/search/view/search_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'cart_cubit_test.dart' show dish;
import 'home_screen_test.dart' show FakeOrderRepository;

class FakeDetailRepository extends RestaurantDetailRepository {
  final Restaurant restaurant;
  final List<MenuItem> menu;

  FakeDetailRepository({required this.restaurant, this.menu = const []})
    : super(Dio());

  @override
  Future<Restaurant> getRestaurantById(int id) async => restaurant;

  @override
  Future<List<MenuItem>> getRestaurantMenu(int id, {MenuSort? sort}) async =>
      menu;
}

class FakeSearchRepository extends SearchRepository {
  final List<MenuItem> dishes;
  final List<Restaurant> restaurants;

  FakeSearchRepository({this.dishes = const [], this.restaurants = const []})
    : super(Dio());

  @override
  Future<List<MenuItem>> searchDishes(String query, {MenuSort? sort}) async =>
      dishes;

  @override
  Future<List<Restaurant>> searchRestaurants(String query) async => restaurants;
}

const _restaurant = Restaurant(
  restaurantID: 1,
  restaurantName: 'Paradise Biryani',
  address: 'Hyderabad, Secunderabad, Telangana',
  type: 'Biryani',
  parkingLot: true,
);

/// Wraps [child] with the providers and localizations every screen needs.
Future<CartCubit> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size size = const Size(375, 812),
  CartCubit? cart,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final cartCubit = cart ?? CartCubit(FakeOrderRepository());

  await tester.pumpWidget(
    BlocProvider.value(
      value: cartCubit,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cartCubit;
}

/// A RenderFlex overflow throws during layout, so a clean pump is the
/// assertion. Runs each screen on a small phone, at a large text scale, and in
/// Arabic — the three ways layout breaks for real users.
void layoutSuite(String name, Widget Function() build) {
  group('$name layout', () {
    testWidgets('standard phone', (tester) async {
      await pumpScreen(tester, build());
      expect(tester.takeException(), isNull);
    });

    testWidgets('small phone', (tester) async {
      await pumpScreen(tester, build(), size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.6x text scale', (tester) async {
      await pumpScreen(tester, build(), textScale: 1.6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic', (tester) async {
      await pumpScreen(tester, build(), locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });
  });
}

void main() {
  layoutSuite('empty cart', () => const CartScreen());

  layoutSuite('food details', () => FoodDetailsScreen(item: dish(1)));

  layoutSuite(
    'restaurant view',
    () => BlocProvider(
      create: (_) => RestaurantDetailCubit(
        FakeDetailRepository(
          restaurant: _restaurant,
          menu: [
            dish(1),
            dish(2, name: 'Sheer Korma'),
          ],
        ),
      ),
      child: const RestaurantDetailScreen(restaurantId: 1),
    ),
  );

  layoutSuite(
    'orders',
    () => BlocProvider(
      create: (_) => OrdersCubit(
        FakeOrderRepository(
          orders: const [
            Order(
              id: '12',
              restaurantName: 'Paradise Biryani',
              total: 750,
              lines: [OrderLine(itemName: 'Kofta Curry', quantity: 2)],
            ),
          ],
        ),
      )..load(),
      child: const OrdersScreen(),
    ),
  );

  layoutSuite(
    'search',
    () => BlocProvider(
      create: (_) => SearchCubit(FakeSearchRepository()),
      child: const SearchScreen(),
    ),
  );

  group('cart screen', () {
    testWidgets('shows the empty state with nothing in it', (tester) async {
      await pumpScreen(tester, const CartScreen());
      expect(find.text('Your cart is empty'), findsOneWidget);
    });

    testWidgets('lists lines and the total', (tester) async {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1, name: 'Kofta Curry', price: 300), quantity: 2);

      await pumpScreen(tester, const CartScreen(), cart: cart);

      expect(find.text('Kofta Curry'), findsOneWidget);
      // 300 x 2, formatted as rupees with no decimals.
      expect(find.text('₹600'), findsWidgets);
      expect(find.text('PLACE ORDER'), findsOneWidget);
    });

    testWidgets('stepping a single item down removes it', (tester) async {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1), quantity: 1);

      await pumpScreen(tester, const CartScreen(), cart: cart);
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(cart.state.isEmpty, isTrue);
      expect(find.text('Your cart is empty'), findsOneWidget);
    });
  });

  group('food details', () {
    testWidgets('multiplies the price by the quantity', (tester) async {
      await pumpScreen(tester, FoodDetailsScreen(item: dish(1, price: 300)));

      expect(find.text('₹300'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('₹600'), findsOneWidget);
    });

    testWidgets('cannot step below one', (tester) async {
      await pumpScreen(tester, FoodDetailsScreen(item: dish(1, price: 300)));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('₹300'), findsOneWidget);
    });

    testWidgets('adds the chosen quantity to the cart', (tester) async {
      final cart = await pumpScreen(
        tester,
        FoodDetailsScreen(item: dish(1, name: 'Kofta Curry')),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADD TO CART'));
      await tester.pumpAndSettle();

      expect(cart.state.quantityOf(1), 2);
    });
  });

  testWidgets('orders screen lists an order with its lines', (tester) async {
    await pumpScreen(
      tester,
      BlocProvider(
        create: (_) => OrdersCubit(
          FakeOrderRepository(
            orders: const [
              Order(
                id: '12',
                restaurantName: 'Paradise Biryani',
                total: 750,
                lines: [OrderLine(itemName: 'Kofta Curry', quantity: 2)],
              ),
            ],
          ),
        )..load(),
        child: const OrdersScreen(),
      ),
    );

    expect(find.text('Paradise Biryani'), findsOneWidget);
    expect(find.text('#12'), findsOneWidget);
    expect(find.text('₹750'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.textContaining('2× Kofta Curry'), findsOneWidget);
  });

  testWidgets('search prompts before anything is typed', (tester) async {
    await pumpScreen(
      tester,
      BlocProvider(
        create: (_) => SearchCubit(FakeSearchRepository()),
        child: const SearchScreen(),
      ),
    );

    expect(find.text('Search for a dish or a restaurant'), findsOneWidget);
  });
}
