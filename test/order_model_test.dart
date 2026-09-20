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
}
