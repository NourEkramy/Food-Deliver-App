import 'package:dio/dio.dart';

import '../../restaurant_detail/model/menu_item.dart';
import '../../restaurant_detail/repository/restaurant_detail_repository.dart';
import '../../restaurant_list/model/restaurant.dart';

/// Searches the API rather than filtering a downloaded list.
///
/// The home screen filters locally because it already holds every restaurant.
/// Dishes are different: there are 93 across all restaurants and the server
/// does substring matching and price ordering, so the work belongs there.
class SearchRepository {
  final Dio dio;

  SearchRepository(this.dio);

  Future<List<MenuItem>> searchDishes(String query, {MenuSort? sort}) async {
    try {
      final response = await dio.get(
        '/Restaurant/items',
        queryParameters: {
          if (query.isNotEmpty) 'ItemName': query,
          if (sort != null)
            'sortbyprice': sort == MenuSort.priceAscending ? 'asc' : 'desc',
        },
      );
      final data = response.data;
      if (data is! List) return const [];
      return data
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await dio.get(
        '/Restaurant',
        queryParameters: {if (query.isNotEmpty) 'name': query},
      );
      final data = response.data;
      if (data is! List) return const [];
      return data
          .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  String _message(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'The server took too long to respond.',
    DioExceptionType.connectionError =>
      'No internet connection. Please check your network.',
    _ => 'Search failed',
  };
}
