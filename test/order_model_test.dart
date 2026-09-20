import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:food_delivery/features/orders/model/order.dart';
import 'package:food_delivery/features/orders/repository/order_repository.dart';

import 'auth_repository_test.dart' show StubAdapter;

OrderRepository repoWith(StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return OrderRepository(dio);
}

/// The `/Order` response shape could not be inspected while this was written —
/// the endpoint needs an API key. So the parser accepts several plausible
/// spellings, and these tests pin that tolerance down.
void main() {
  test('parses the documented shape', () {
    final order = Order.tryParse({
      'masterID': 12,
      'restaurantName': 'Paradise Biryani',
      'restaurantID': 1,
      'total': 750.0,
      'orderDate': '2026-09-19T10:30:00',
      'menuDTO': [
        {'itemName': 'Kofta Curry', 'quantity': 2, 'itemPrice': 300.0},
        {'itemName': 'Sheer Korma', 'quantity': 1, 'itemPrice': 150.0},
      ],
    });

    expect(order, isNotNull);
    expect(order!.id, '12');
    expect(order.restaurantName, 'Paradise Biryani');
    expect(order.total, 750.0);
    expect(order.placedAt?.year, 2026);
    expect(order.lines, hasLength(2));
    expect(order.itemCount, 3);
  });

  test('accepts alternative key spellings', () {
    final order = Order.tryParse({
      'orderId': 'AB-9',
      'restaurant': 'Britannia',
      'totalPrice': '420.50',
      'items': [
        {'name': 'Berry Pulao', 'qty': 2},
      ],
    });

    expect(order!.id, 'AB-9');
    expect(order.restaurantName, 'Britannia');
    expect(order.total, 420.50);
    expect(order.lines.single.itemName, 'Berry Pulao');
    expect(order.lines.single.quantity, 2);
  });

  test('returns null when nothing identifies an order', () {
    expect(Order.tryParse({'restaurantName': 'X'}), isNull);
    expect(Order.tryParse('not a map'), isNull);
    expect(Order.tryParse(null), isNull);
  });

  test('survives a payload with only an id', () {
    final order = Order.tryParse({'masterID': 3});

    // Everything optional is absent rather than throwing — the card renders
    // sparsely instead of the screen failing.
    expect(order!.id, '3');
    expect(order.restaurantName, isNull);
    expect(order.total, isNull);
    expect(order.placedAt, isNull);
    expect(order.lines, isEmpty);
    expect(order.itemCount, 0);
  });

  test('skips malformed lines instead of failing the order', () {
    final order = Order.tryParse({
      'id': 1,
      'items': [
        'junk',
        {'quantity': 2},
        {'itemName': 'Real Dish', 'quantity': 4},
      ],
    });

    expect(order!.lines, hasLength(1));
    expect(order.lines.single.itemName, 'Real Dish');
    expect(order.itemCount, 4);
  });

  test('defaults a missing quantity to one', () {
    final order = Order.tryParse({
      'id': 1,
      'items': [
        {'itemName': 'Lone Dish'},
      ],
    });

    expect(order!.lines.single.quantity, 1);
  });

  group('the shape the live API actually returns', () {
    // Confirmed from a real run: makeorder answered 201 with
    // {fullorder, grandTotal}. The first parser guessed `total` and `menuDTO`,
    // so orders rendered with no total and "0 items".
    test('reads grandTotal and fullorder', () {
      final order = Order.tryParse({
        'masterID': 317,
        'grandTotal': 500.0,
        'fullorder': [
          {
            'itemName': 'Laal Maas',
            'quantity': 1,
            'itemPrice': 500.0,
            'restaurantName': '1135 AD',
          },
        ],
      });

      expect(order!.id, '317');
      expect(order.total, 500.0);
      expect(order.itemCount, 1);
      expect(order.lines.single.itemName, 'Laal Maas');
    });

    test('takes the restaurant name from the lines', () {
      // The order itself carries no restaurantName; every line does.
      final order = Order.tryParse({
        'masterID': 317,
        'grandTotal': 500.0,
        'fullorder': [
          {'itemName': 'Laal Maas', 'quantity': 1, 'restaurantName': '1135 AD'},
        ],
      });

      expect(order!.restaurantName, '1135 AD');
    });

    test('accepts fullorder as a single object, not just a list', () {
      final order = Order.tryParse({
        'masterID': 318,
        'fullorder': {'itemName': 'Dal Baati Churma', 'quantity': 2},
      });

      expect(order!.lines, hasLength(1));
      expect(order.itemCount, 2);
    });

    test('an order with no lines reports no items rather than guessing', () {
      final order = Order.tryParse({'masterID': 318});

      expect(order!.itemCount, 0);
      expect(order.restaurantName, isNull);
    });
  });

  group('getOrderById', () {
    test('parses a single order object', () async {
      final adapter = StubAdapter({
        '/Order/317': (
          200,
          {
            'masterID': 317,
            'grandTotal': 500.0,
            'fullorder': [
              {
                'itemName': 'Laal Maas',
                'quantity': 1,
                'restaurantName': '1135 AD',
              },
            ],
          },
        ),
      });

      final order = await repoWith(adapter).getOrderById('317');

      expect(order!.id, '317');
      expect(order.total, 500.0);
      expect(order.restaurantName, '1135 AD');
      expect(adapter.calls, ['/Order/317']);
    });

    test('unwraps an order returned inside a one-item list', () async {
      // The list and detail endpoints may not agree on shape; accept both.
      final adapter = StubAdapter({
        '/Order/317': (
          200,
          [
            {'masterID': 317, 'grandTotal': 250.0},
          ],
        ),
      });

      final order = await repoWith(adapter).getOrderById('317');

      expect(order!.id, '317');
      expect(order.total, 250.0);
    });

    test('returns null when the payload identifies no order', () async {
      final adapter = StubAdapter({'/Order/999': (200, <String, Object>{})});

      expect(await repoWith(adapter).getOrderById('999'), isNull);
    });
  });
}
