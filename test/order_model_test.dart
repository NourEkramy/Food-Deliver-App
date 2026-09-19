import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/features/orders/model/order.dart';

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
}
