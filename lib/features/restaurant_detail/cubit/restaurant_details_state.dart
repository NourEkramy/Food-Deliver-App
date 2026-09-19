import 'package:equatable/equatable.dart';
import '../../restaurant_list/model/restaurant.dart';
import '../model/menu_item.dart';
import '../repository/restaurant_detail_repository.dart';

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

  /// The sort currently applied, so the control can show which is active.
  final MenuSort? sort;

  /// True while a re-sort is in flight. The menu stays on screen and only the
  /// control shows activity, rather than the whole page dropping to a spinner.
  final bool isSorting;

  const RestaurantDetailLoaded({
    required this.restaurant,
    required this.menuItems,
    this.sort,
    this.isSorting = false,
  });

  RestaurantDetailLoaded copyWith({
    List<MenuItem>? menuItems,
    MenuSort? sort,
    bool? isSorting,
    bool clearSort = false,
  }) {
    return RestaurantDetailLoaded(
      restaurant: restaurant,
      menuItems: menuItems ?? this.menuItems,
      sort: clearSort ? null : (sort ?? this.sort),
      isSorting: isSorting ?? false,
    );
  }

  @override
  List<Object?> get props => [restaurant, menuItems, sort, isSorting];
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;

  const RestaurantDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
