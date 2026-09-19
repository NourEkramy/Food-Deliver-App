import 'package:dio/dio.dart';

import '../model/restaurant.dart';

class RestaurantRepository {
  final Dio dio;

  RestaurantRepository(this.dio);

  /// Restaurants, each decorated with a photo and a dish count.
  ///
  /// `/Restaurant` carries no image field, so a second call to
  /// `/Restaurant/items` supplies one photo per restaurant — 93 items in a
  /// single request, rather than one request per restaurant. Merging happens
  /// here so the Cubit and the widgets never learn there were two calls.
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      // Both go out together rather than one after the other.
      final restaurantsRequest = dio.get('/Restaurant');
      final itemsRequest = _allItemsOrEmpty();

      final response = await restaurantsRequest;
      final restaurants = (response.data as List)
          .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
          .toList();

      return _decorate(restaurants, await itemsRequest);
    } on DioException catch (e) {
      throw Exception('Failed to load restaurants: ${e.message}');
    }
  }

  /// Every menu item, or an empty list if that call fails.
  ///
  /// Swallowing the error is deliberate: this screen exists to list
  /// restaurants. A failure here should cost a plainer-looking card, not the
  /// whole screen.
  Future<List> _allItemsOrEmpty() async {
    try {
      final response = await dio.get('/Restaurant/items');
      return response.data as List;
    } catch (_) {
      return const [];
    }
  }

  List<Restaurant> _decorate(List<Restaurant> restaurants, List items) {
    final firstImage = <int, String>{};
    final dishCounts = <int, int>{};

    for (final raw in items) {
      if (raw is! Map) continue;
      final id = raw['restaurantID'];
      if (id is! int) continue;

      dishCounts[id] = (dishCounts[id] ?? 0) + 1;

      final url = raw['imageUrl'];
      if (url is String && url.isNotEmpty) {
        // putIfAbsent: the first item's photo represents the restaurant.
        firstImage.putIfAbsent(id, () => url);
      }
    }

    return restaurants
        .map(
          (r) => r.copyWith(
            imageUrl: firstImage[r.restaurantID],
            dishCount: dishCounts[r.restaurantID] ?? 0,
          ),
        )
        .toList();
  }
}
