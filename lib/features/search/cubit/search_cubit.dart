import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../restaurant_detail/repository/restaurant_detail_repository.dart';
import '../repository/search_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository repository;

  Timer? _debounce;

  SearchCubit(this.repository) : super(const SearchState());

  /// Waits for a pause in typing before hitting the network.
  ///
  /// Without this every keystroke fires two requests, and slow responses can
  /// land out of order so an earlier query overwrites a later one.
  static const _debounceDelay = Duration(milliseconds: 350);

  void queryChanged(String query) {
    emit(state.copyWith(query: query));

    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          dishes: const [],
          restaurants: const [],
          isLoading: false,
          hasSearched: false,
        ),
      );
      return;
    }

    _debounce = Timer(_debounceDelay, _run);
  }

  void sortChanged(MenuSort? sort) {
    emit(state.copyWith(sort: sort, clearSort: sort == null));
    if (state.query.trim().isNotEmpty) _run();
  }

  Future<void> _run() async {
    final query = state.query.trim();
    if (query.isEmpty) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Record `.wait` rather than Future.wait: both run in parallel, but the
      // result keeps each type instead of collapsing to List<dynamic>.
      final (dishes, restaurants) = await (
        repository.searchDishes(query, sort: state.sort),
        repository.searchRestaurants(query),
      ).wait;

      // A slower earlier search must not overwrite a newer query's results.
      if (state.query.trim() != query) return;

      emit(
        state.copyWith(
          isLoading: false,
          dishes: dishes,
          restaurants: restaurants,
          hasSearched: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          hasSearched: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
