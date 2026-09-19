import 'package:flutter_bloc/flutter_bloc.dart';

import '../../orders/repository/order_repository.dart';
import '../../restaurant_detail/model/menu_item.dart';
import '../model/cart_item.dart';
import 'cart_state.dart';

/// Holds the cart and sends it to the server at checkout.
///
/// The cart itself is local: the API has no cart endpoint, only
/// `makeorder`, which takes the whole basket in one request. So contents live
/// in memory until the user checks out. Closing the app loses the cart —
/// acceptable, and the alternative (persisting it) would need reconciling with
/// a menu that may have changed.
class CartCubit extends Cubit<CartState> {
  final OrderRepository repository;

  CartCubit(this.repository) : super(const CartState());

  /// Adds [quantity] of [item], merging with any line already holding it.
  ///
  /// Call [CartState.acceptsFrom] first: adding a dish from another restaurant
  /// silently replaces the cart, which should always be the user's choice.
  void add(MenuItem item, {int quantity = 1}) {
    if (quantity < 1) return;

    if (!state.acceptsFrom(item.restaurantID)) {
      // Different restaurant: start over rather than build an order the API
      // cannot express.
      emit(
        state.copyWith(
          items: [CartItem(item: item, quantity: quantity)],
        ),
      );
      return;
    }

    final items = [...state.items];
    final index = items.indexWhere((line) => line.item.itemID == item.itemID);

    if (index == -1) {
      items.add(CartItem(item: item, quantity: quantity));
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    }

    emit(state.copyWith(items: items));
  }

  /// Sets an exact quantity. Zero or less removes the line.
  void setQuantity(int itemId, int quantity) {
    if (quantity <= 0) {
      remove(itemId);
      return;
    }

    final items = [
      for (final line in state.items)
        if (line.item.itemID == itemId)
          line.copyWith(quantity: quantity)
        else
          line,
    ];

    emit(state.copyWith(items: items));
  }

  void increment(int itemId) =>
      setQuantity(itemId, state.quantityOf(itemId) + 1);

  void decrement(int itemId) =>
      setQuantity(itemId, state.quantityOf(itemId) - 1);

  void remove(int itemId) {
    emit(
      state.copyWith(
        items: state.items.where((line) => line.item.itemID != itemId).toList(),
      ),
    );
  }

  void clear() => emit(const CartState());

  /// Sends the cart as a real order, then empties it.
  Future<void> placeOrder() async {
    final restaurantId = state.restaurantId;
    if (state.isEmpty || restaurantId == null || state.isPlacing) return;

    emit(state.copyWith(isPlacing: true));

    try {
      // The API keys lines on itemName. Two different dishes could in principle
      // share a name; summing quantities here means the order stays correct
      // rather than one line silently overwriting the other.
      final quantities = <String, int>{};
      for (final line in state.items) {
        quantities[line.item.itemName] =
            (quantities[line.item.itemName] ?? 0) + line.quantity;
      }

      await repository.placeOrder(
        restaurantId: restaurantId,
        quantitiesByItemName: quantities,
      );

      emit(const CartState(justPlacedOrder: true));
    } catch (e) {
      emit(
        state.copyWith(
          isPlacing: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
