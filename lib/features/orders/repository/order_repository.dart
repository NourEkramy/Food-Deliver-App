import 'package:dio/dio.dart';

import '../model/order.dart';

/// Talks to `/Order`.
///
/// Every endpoint here needs `?apikey=`, which [ApiKeyInterceptor] attaches to
/// each request — so nothing in this file mentions the key.
class OrderRepository {
  final Dio dio;

  OrderRepository(this.dio);

  Future<List<Order>> getOrders() async {
    try {
      final response = await dio.get('/Order');
      final data = response.data;
      if (data is! List) return const [];

      // Rows that cannot be parsed are skipped rather than failing the screen.
      return data
          .map(Order.tryParse)
          .whereType<Order>()
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception(
        _readableError(e, fallback: 'Could not load your orders'),
      );
    }
  }

  /// One order, in full.
  ///
  /// `GET /Order` may only return summaries — that has not been confirmed
  /// against a live account — so this is where an order's dishes can always be
  /// read, whatever the list contains.
  Future<Order?> getOrderById(String masterId) async {
    try {
      final response = await dio.get('/Order/$masterId');
      final data = response.data;

      // A single order may arrive on its own or wrapped in a one-item list.
      final raw = data is List ? data.firstOrNull : data;
      return Order.tryParse(raw);
    } on DioException catch (e) {
      throw Exception(_readableError(e, fallback: 'Could not load that order'));
    }
  }

  /// Places an order for one restaurant.
  ///
  /// The restaurant is part of the URL and the API keys the lines on
  /// **itemName**, not itemID — which is why the cart has to carry names, and
  /// why a single order cannot span restaurants.
  Future<void> placeOrder({
    required int restaurantId,
    required Map<String, int> quantitiesByItemName,
  }) async {
    try {
      await dio.post(
        '/Order/$restaurantId/makeorder',
        data: {
          'menuDTO': quantitiesByItemName.entries
              .map((e) => {'itemName': e.key, 'quantity': e.value})
              .toList(),
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _readableError(e, fallback: 'Could not place your order'),
      );
    }
  }

  /// Cancels a whole order group.
  Future<void> cancelOrder(String masterId) async {
    try {
      await dio.delete('/Order/master/$masterId');
    } on DioException catch (e) {
      throw Exception(
        _readableError(e, fallback: 'Could not cancel that order'),
      );
    }
  }

  String _readableError(DioException e, {required String fallback}) {
    final data = e.response?.data;

    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;

      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values
            .whereType<List>()
            .expand((list) => list)
            .whereType<String>()
            .firstOrNull;
        if (first != null) return first;
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'The server took too long to respond.',
      DioExceptionType.connectionError =>
        'No internet connection. Please check your network.',
      _ => fallback,
    };
  }
}
