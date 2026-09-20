import 'package:flutter/material.dart';

import '../../../core/widgets/app_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/util/money.dart';
import '../../../core/widgets/cart_badge_button.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes.dart';
import '../../cart/view/add_to_cart.dart';
import '../model/menu_item.dart';

/// One dish, with a quantity to add to the cart.
///
/// The design also shows a rating, a size selector and an ingredient strip.
/// None of those exist in the API — a menu item is a name, a description, a
/// price, a photo and its restaurant — so they are left out rather than faked.
class FoodDetailsScreen extends StatefulWidget {
  final MenuItem item;

  const FoodDetailsScreen({super.key, required this.item});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;

  Future<void> _add() async {
    final added = await addToCart(context, widget.item, quantity: _quantity);
    if (added && mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.details,
              trailing: CartBadgeButton(
                onTap: () => AppRoutes.openCart(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppNetworkImage(url: item.imageUrl, fallbackIconSize: 44),
                    const SizedBox(height: 20),
                    // The restaurant chip from the design — this one is real.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          // Flexible: a long restaurant name, or a large
                          // accessibility text scale, must shrink the chip
                          // rather than push it past the screen edge.
                          Flexible(
                            child: Text(
                              item.restaurantName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.itemDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomBar(
              price: item.itemPrice * _quantity,
              quantity: _quantity,
              onIncrement: () => setState(() => _quantity++),
              onDecrement: () => setState(() => _quantity--),
              onAdd: _add,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double price;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAdd;

  const _BottomBar({
    required this.price,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // The running total, not the unit price: what the user is
                  // about to add.
                  formatPrice(context, price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              QuantityStepper(
                quantity: quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onDark: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              child: Text(l10n.addToCart),
            ),
          ),
        ],
      ),
    );
  }
}
