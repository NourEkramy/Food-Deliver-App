import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/features/restaurant_detail/cubit/restaurant_details_state.dart';
import 'package:food_delivery/features/restaurant_detail/model/menu_item.dart';
import 'package:food_delivery/features/restaurant_list/model/restaurant.dart';
import '../repository/restaurant_detail_repository.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  final RestaurantDetailRepository repository;

  RestaurantDetailCubit(this.repository) : super(RestaurantDetailInitial());

  Future<void> loadRestaurantDetail(int restaurantId) async {
    emit(RestaurantDetailLoading());
    try {
      final results = await Future.wait([
        repository.getRestaurantById(restaurantId),
        repository.getRestaurantMenu(restaurantId),
      ]);

      emit(
        RestaurantDetailLoaded(
          restaurant: results[0] as Restaurant,
          menuItems: results[1] as List<MenuItem>,
        ),
      );
    } catch (e) {
      emit(RestaurantDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Re-fetches the menu in a different order.
  ///
  /// Sorting happens on the server (`?sortbyprice=`) rather than in Dart. With
  /// a handful of dishes either would do, but using the endpoint keeps the
  /// ordering correct for a menu of any size.
  Future<void> sortMenu(MenuSort? sort) async {
    final current = state;
    if (current is! RestaurantDetailLoaded || current.isSorting) return;
    if (current.sort == sort) return;

    emit(current.copyWith(isSorting: true));
    try {
      final items = await repository.getRestaurantMenu(
        current.restaurant.restaurantID,
        sort: sort,
      );
      emit(
        current.copyWith(
          menuItems: items,
          sort: sort,
          clearSort: sort == null,
          isSorting: false,
        ),
      );
    } catch (e) {
      // Keep the menu that is already on screen; only report the failure.
      emit(current.copyWith(isSorting: false));
    }
  }
}
