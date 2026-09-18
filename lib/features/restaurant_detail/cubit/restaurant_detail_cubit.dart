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
      final restaurant = results[0] as Restaurant;
      final menuItems = results[1] as List<MenuItem>;

      emit(
        RestaurantDetailLoaded(restaurant: restaurant, menuItems: menuItems),
      );
    } catch (e) {
      emit(RestaurantDetailError(e.toString()));
    }
  }
}
