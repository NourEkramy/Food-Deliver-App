import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../restaurant_detail/model/menu_item.dart';
import '../cubit/cart_cubit.dart';

/// Adds [item] to the cart, asking first if that would empty an existing cart.
///
/// `POST /Order/{restaurant_id}/makeorder` puts the restaurant in the URL, so
/// an order cannot span restaurants. Rather than let that surface as a
/// confusing failure at checkout, the conflict is raised at the moment it is
/// created — and emptying someone's cart is never done silently.
///
/// Returns true if the item was added.
Future<bool> addToCart(
  BuildContext context,
  MenuItem item, {
  int quantity = 1,
}) async {
  final l10n = AppLocalizations.of(context);
  final cart = context.read<CartCubit>();
  final messenger = ScaffoldMessenger.of(context);

  if (!cart.state.acceptsFrom(item.restaurantID)) {
    final existing = cart.state.restaurantName ?? '';

    final replace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newCartTitle),
        content: Text(l10n.newCartBody(existing)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepCart),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.startNewCart),
          ),
        ],
      ),
    );

    if (replace != true) return false;
  }

  cart.add(item, quantity: quantity);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.addedToCart),
        duration: const Duration(seconds: 2),
      ),
    );

  return true;
}
