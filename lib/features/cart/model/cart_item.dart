import 'package:equatable/equatable.dart';

import '../../restaurant_detail/model/menu_item.dart';

/// A dish in the cart, with how many of it.
class CartItem extends Equatable {
  final MenuItem item;
  final int quantity;

  const CartItem({required this.item, required this.quantity});

  double get lineTotal => item.itemPrice * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(item: item, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [item.itemID, quantity];
}
