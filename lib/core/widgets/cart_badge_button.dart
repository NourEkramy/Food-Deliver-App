import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/cart/cubit/cart_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// The dark cart circle with its orange count badge.
///
/// Reads the count straight from [CartCubit], so every screen showing it stays
/// in step without passing the number down. Takes an [onTap] rather than
/// navigating itself, so this stays a presentation widget.
class CartBadgeButton extends StatelessWidget {
  final VoidCallback onTap;

  const CartBadgeButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // select, not watch: this rebuilds when the count changes, not on every
    // unrelated cart emission.
    final count = context.select<CartCubit, int>(
      (cubit) => cubit.state.totalQuantity,
    );

    return Stack(
      // The badge overhangs the circle, so it must not be clipped.
      clipBehavior: Clip.none,
      children: [
        Tooltip(
          message: l10n.cart,
          child: Material(
            color: AppColors.dark,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox(
                height: 45,
                width: 45,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
        if (count > 0)
          PositionedDirectional(
            top: -4,
            end: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              constraints: const BoxConstraints(minWidth: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
