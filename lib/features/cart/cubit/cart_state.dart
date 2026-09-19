import 'package:equatable/equatable.dart';

import '../model/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  /// True while the order is being sent.
  final bool isPlacing;

  /// Set once an order is placed successfully, so the screen can react and
  /// then clear. Nothing else depends on it.
  final bool justPlacedOrder;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isPlacing = false,
    this.justPlacedOrder = false,
    this.errorMessage,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// Every dish in the cart belongs to this restaurant.
  ///
  /// `POST /Order/{restaurant_id}/makeorder` puts the restaurant in the URL, so
  /// one order cannot span restaurants — which makes this a property of the
  /// cart as a whole rather than of each line.
  int? get restaurantId => items.isEmpty ? null : items.first.item.restaurantID;

  String? get restaurantName =>
      items.isEmpty ? null : items.first.item.restaurantName;

  int get totalQuantity => items.fold(0, (sum, line) => sum + line.quantity);

  double get total => items.fold(0.0, (sum, line) => sum + line.lineTotal);

  /// Whether a dish from [restaurantId] can join this cart without emptying it.
  bool acceptsFrom(int restaurantId) =>
      isEmpty || this.restaurantId == restaurantId;

  int quantityOf(int itemId) {
    for (final line in items) {
      if (line.item.itemID == itemId) return line.quantity;
    }
    return 0;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isPlacing,
    bool? justPlacedOrder,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isPlacing: isPlacing ?? this.isPlacing,
      justPlacedOrder: justPlacedOrder ?? false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, isPlacing, justPlacedOrder, errorMessage];
}
