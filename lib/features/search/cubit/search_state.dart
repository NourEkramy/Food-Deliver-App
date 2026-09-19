import 'package:equatable/equatable.dart';

import '../../restaurant_detail/model/menu_item.dart';
import '../../restaurant_detail/repository/restaurant_detail_repository.dart';
import '../../restaurant_list/model/restaurant.dart';

class SearchState extends Equatable {
  final String query;
  final bool isLoading;
  final List<MenuItem> dishes;
  final List<Restaurant> restaurants;
  final MenuSort? sort;
  final String? errorMessage;

  /// False until the first search runs, so the screen can show a prompt
  /// instead of an empty-results message before anything has been typed.
  final bool hasSearched;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.dishes = const [],
    this.restaurants = const [],
    this.sort,
    this.errorMessage,
    this.hasSearched = false,
  });

  bool get isEmpty => dishes.isEmpty && restaurants.isEmpty;

  SearchState copyWith({
    String? query,
    bool? isLoading,
    List<MenuItem>? dishes,
    List<Restaurant>? restaurants,
    MenuSort? sort,
    bool clearSort = false,
    String? errorMessage,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      dishes: dishes ?? this.dishes,
      restaurants: restaurants ?? this.restaurants,
      sort: clearSort ? null : (sort ?? this.sort),
      errorMessage: errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props => [
    query,
    isLoading,
    dishes,
    restaurants,
    sort,
    errorMessage,
    hasSearched,
  ];
}
