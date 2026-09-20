import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/cart/view/cart_screen.dart';
import 'features/orders/cubit/orders_cubit.dart';
import 'features/orders/repository/order_repository.dart';
import 'features/orders/cubit/order_detail_cubit.dart';
import 'features/orders/view/order_detail_screen.dart';
import 'features/orders/view/orders_screen.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'features/profile/repository/profile_repository.dart';
import 'features/profile/view/change_password_screen.dart';
import 'features/profile/view/edit_profile_screen.dart';
import 'features/profile/view/profile_screen.dart';
import 'features/restaurant_detail/cubit/restaurant_detail_cubit.dart';
import 'features/restaurant_detail/model/menu_item.dart';
import 'features/restaurant_detail/repository/restaurant_detail_repository.dart';
import 'features/restaurant_detail/view/food_details_screen.dart';
import 'features/restaurant_detail/view/restaurant_detail_screen.dart';
import 'features/search/cubit/search_cubit.dart';
import 'features/search/repository/search_repository.dart';
import 'features/search/view/search_screen.dart';

/// Where navigation lives.
///
/// Screens that need a Cubit of their own get it built here rather than at each
/// call site. Previously every `Navigator.push` restated the BlocProvider and
/// the repository it needed, which meant a screen reachable from three places
/// had that wiring copied three times — and one of those copies was missing its
/// provider entirely, crashing on arrival.
///
/// Cubits that must outlive a single screen — auth and the cart — are provided
/// once in `app.dart` instead, and are simply inherited here.
class AppRoutes {
  const AppRoutes._();

  static Future<void> openRestaurant(BuildContext context, int restaurantId) {
    final dio = context.read<ApiClient>().dio;

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => RestaurantDetailCubit(RestaurantDetailRepository(dio)),
          child: RestaurantDetailScreen(restaurantId: restaurantId),
        ),
      ),
    );
  }

  /// The item screen needs no Cubit: it reads one dish it was handed and talks
  /// only to the app-wide cart.
  static Future<void> openFoodDetails(BuildContext context, MenuItem item) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => FoodDetailsScreen(item: item)));
  }

  static Future<void> openCart(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  static Future<void> openOrders(BuildContext context) {
    final dio = context.read<ApiClient>().dio;

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OrdersCubit(OrderRepository(dio))..load(),
          child: const OrdersScreen(),
        ),
      ),
    );
  }

  /// The three profile screens each get their own ProfileCubit.
  ///
  /// Pushing a route does not carry a provider with it, and none of them needs
  /// to observe the others — each performs one action and pops.
  static Future<void> openProfile(BuildContext context) =>
      _pushWithProfileCubit(context, const ProfileScreen());

  static Future<void> openEditProfile(BuildContext context) =>
      _pushWithProfileCubit(context, const EditProfileScreen());

  static Future<void> openChangePassword(BuildContext context) =>
      _pushWithProfileCubit(context, const ChangePasswordScreen());

  static Future<void> _pushWithProfileCubit(
    BuildContext context,
    Widget screen,
  ) {
    final dio = context.read<ApiClient>().dio;
    final auth = context.read<AuthCubit>();

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ProfileCubit(ProfileRepository(dio), auth),
          child: screen,
        ),
      ),
    );
  }

  static Future<void> openOrderDetail(BuildContext context, String orderId) {
    final dio = context.read<ApiClient>().dio;

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OrderDetailCubit(OrderRepository(dio)),
          child: OrderDetailScreen(orderId: orderId),
        ),
      ),
    );
  }

  static Future<void> openSearch(BuildContext context) {
    final dio = context.read<ApiClient>().dio;

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SearchCubit(SearchRepository(dio)),
          child: const SearchScreen(),
        ),
      ),
    );
  }
}
