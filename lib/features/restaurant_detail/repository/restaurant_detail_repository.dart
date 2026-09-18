import 'package:dio/dio.dart';
import '../../restaurant_list/model/restaurant.dart';
import '../model/menu_item.dart';

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

  Future<List<MenuItem>> getRestaurantMenu(int id) async {
    try {
      final response = await dio.get('/Restaurant/$id/menu');
      final data = response.data as List;
      return data.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load menu: ${e.message}');
    }
  }
}