import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/features/restaurant_list/repository/restaurant_repository.dart';
import 'package:food_delivery/features/restaurant_list/cubit/restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final RestaurantRepository repository;

  RestaurantCubit(this.repository) : super(RestaurantInitial());

  Future<void> loadRestaurants() async {
    emit(RestaurantLoading());
    try {
      final restaurants = await repository.getAllRestaurants();
      emit(RestaurantLoaded(restaurants));
    } catch (e) {
      emit(RestaurantError(e.toString()));
    }
  }
}