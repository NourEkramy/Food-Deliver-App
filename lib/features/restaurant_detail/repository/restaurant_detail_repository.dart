import 'package:dio/dio.dart';
import '../../restaurant_list/model/restaurant.dart';
import '../model/menu_item.dart';

/// How the menu should be ordered. `null` leaves the server's own order.
enum MenuSort { priceAscending, priceDescending }

extension on MenuSort {
  /// The value the API expects for `?sortbyprice=`.
  String get query => this == MenuSort.priceAscending ? 'asc' : 'desc';
}

class RestaurantDetailRepository {
  final Dio dio;

  RestaurantDetailRepository(this.dio);

  Future<Restaurant> getRestaurantById(int id) async {
    try {
      final response = await dio.get('/Restaurant/$id');
      return Restaurant.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to load restaurant: ${e.message}');
    }
  }

  /// The restaurant's menu, optionally sorted by price on the server.
  Future<List<MenuItem>> getRestaurantMenu(int id, {MenuSort? sort}) async {
    try {
      final response = await dio.get(
        '/Restaurant/$id/menu',
        queryParameters: {if (sort != null) 'sortbyprice': sort.query},
      );
      final data = response.data as List;
      return data
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to load menu: ${e.message}');
    }
  }
}
