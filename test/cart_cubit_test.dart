import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/features/cart/cubit/cart_cubit.dart';
import 'package:food_delivery/features/restaurant_detail/model/menu_item.dart';

import 'home_screen_test.dart' show FakeOrderRepository;

MenuItem dish(
  int id, {
  String name = 'Kofta Curry',
  double price = 300,
  int restaurantId = 1,
  String restaurant = 'Paradise Biryani',
}) {
  return MenuItem(
    itemID: id,
    itemName: name,
    itemDescription: 'x',
    itemPrice: price,
    restaurantName: restaurant,
    restaurantID: restaurantId,
  );
}

void main() {
  group('adding', () {
    test('merges repeat additions of the same dish into one line', () {
      final cart = CartCubit(FakeOrderRepository());

      cart.add(dish(1), quantity: 2);
      cart.add(dish(1), quantity: 3);

      expect(cart.state.items, hasLength(1));
      expect(cart.state.items.single.quantity, 5);
      expect(cart.state.totalQuantity, 5);
    });

    test('keeps different dishes as separate lines', () {
      final cart = CartCubit(FakeOrderRepository());

      cart.add(dish(1, name: 'Kofta Curry', price: 300));
      cart.add(dish(2, name: 'Sheer Korma', price: 150));

      expect(cart.state.items, hasLength(2));
      expect(cart.state.total, 450);
    });

    test('ignores a non-positive quantity', () {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1), quantity: 0);
      expect(cart.state.isEmpty, isTrue);
    });
  });

  group('one restaurant per cart', () {
    test('accepts dishes from the restaurant already in the cart', () {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1, restaurantId: 7));

      expect(cart.state.acceptsFrom(7), isTrue);
      expect(cart.state.acceptsFrom(9), isFalse);
    });

    test('an empty cart accepts anything', () {
      final cart = CartCubit(FakeOrderRepository());
      expect(cart.state.acceptsFrom(42), isTrue);
    });

    test('adding from elsewhere replaces the cart rather than mixing', () {
      // makeorder puts the restaurant in the URL, so a mixed cart could not be
      // expressed as one order.
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1, restaurantId: 7), quantity: 3);

      cart.add(dish(2, restaurantId: 9, restaurant: 'Britannia'));

      expect(cart.state.items, hasLength(1));
      expect(cart.state.restaurantId, 9);
      expect(cart.state.restaurantName, 'Britannia');
    });
  });

  group('quantities', () {
    test('increment and decrement adjust the line', () {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1), quantity: 2);

      cart.increment(1);
      expect(cart.state.quantityOf(1), 3);

      cart.decrement(1);
      expect(cart.state.quantityOf(1), 2);
    });

    test('dropping to zero removes the line entirely', () {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1), quantity: 1);

      cart.decrement(1);

      expect(cart.state.isEmpty, isTrue);
      expect(cart.state.quantityOf(1), 0);
    });

    test('clear empties everything', () {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1));
      cart.add(dish(2));

      cart.clear();

      expect(cart.state.isEmpty, isTrue);
      expect(cart.state.total, 0);
    });
  });

  group('placing an order', () {
    test('sends names and quantities for the cart restaurant', () async {
      final repo = FakeOrderRepository();
      final cart = CartCubit(repo);
      cart.add(dish(1, name: 'Kofta Curry', restaurantId: 7), quantity: 2);
      cart.add(dish(2, name: 'Sheer Korma', restaurantId: 7), quantity: 1);

      await cart.placeOrder();

      expect(repo.placed, hasLength(1));
      expect(repo.placed.single.restaurantId, 7);
      expect(repo.placed.single.items, {'Kofta Curry': 2, 'Sheer Korma': 1});
    });

    test('sums quantities when two lines share a name', () async {
      // The API keys on itemName, so two dishes with the same name must not
      // silently overwrite one another.
      final repo = FakeOrderRepository();
      final cart = CartCubit(repo);
      cart.add(dish(1, name: 'Fish Curry'), quantity: 2);
      cart.add(dish(2, name: 'Fish Curry'), quantity: 3);

      await cart.placeOrder();

      expect(repo.placed.single.items, {'Fish Curry': 5});
    });

    test('empties the cart and flags success', () async {
      final cart = CartCubit(FakeOrderRepository());
      cart.add(dish(1));

      await cart.placeOrder();

      expect(cart.state.isEmpty, isTrue);
      expect(cart.state.justPlacedOrder, isTrue);
    });

    test('keeps the cart and reports the error when it fails', () async {
      final cart = CartCubit(FakeOrderRepository(failWith: 'Invalid API key'));
      cart.add(dish(1), quantity: 2);

      await cart.placeOrder();

      expect(cart.state.errorMessage, 'Invalid API key');
      expect(cart.state.isEmpty, isFalse, reason: 'do not lose their basket');
      expect(cart.state.isPlacing, isFalse);
    });

    test('does nothing on an empty cart', () async {
      final repo = FakeOrderRepository();
      await CartCubit(repo).placeOrder();
      expect(repo.placed, isEmpty);
    });
  });
}
