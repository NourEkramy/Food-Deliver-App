import 'package:dio/dio.dart';

import '../model/restaurant.dart';

class RestaurantRepository {
  final Dio dio;

  RestaurantRepository(this.dio);

  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await dio.get('/Restaurant');

      final data = response.data as List;
      return data.map((json) =>
          Restaurant.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load restaurants: ${e.message}');
    }
  }
}