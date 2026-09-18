import 'package:equatable/equatable.dart';
import '../../restaurant_list/model/restaurant.dart';
import '../model/menu_item.dart';

abstract class RestaurantDetailState extends Equatable {
  const RestaurantDetailState();

  @override
  List<Object?> get props => [];
}

class RestaurantDetailInitial extends RestaurantDetailState {}

class RestaurantDetailLoading extends RestaurantDetailState {}

class RestaurantDetailLoaded extends RestaurantDetailState {
  final Restaurant restaurant;
  final List<MenuItem> menuItems;

  const RestaurantDetailLoaded({
    required this.restaurant,
    required this.menuItems,
  });

  @override
  List<Object?> get props => [restaurant, menuItems];
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;

  const RestaurantDetailError(this.message);

  @override
  List<Object?> get props => [message];
}