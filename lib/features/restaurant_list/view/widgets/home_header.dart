import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The top row of the home screen: menu button, delivery address, cart.
///
/// The address is a placeholder because no address endpoint exists. It reads
/// "Set delivery address" rather than inventing a location, so the screen never
/// claims to know something it does not.
class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;

  /// Shown on the cart badge. The badge is hidden entirely at zero.
  final int cartCount;

  const HomeHeader({
    super.key,
    required this.onMenuTap,
    required this.onCartTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          _CircleButton(
            onTap: onMenuTap,
            tooltip: l10n.menuLabel,
            background: AppColors.surfaceGrey,
            child: const Icon(
              Icons.segment,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.deliveryTo,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.setDeliveryAddress,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CartButton(
            onTap: onCartTap,
            count: cartCount,
            tooltip: l10n.cartLabel,
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color background;
  final String tooltip;

  const _CircleButton({
    required this.onTap,
    required this.child,
    required this.background,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(height: 45, width: 45, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final VoidCallback onTap;
  final int count;
  final String tooltip;

  const _CartButton({
    required this.onTap,
    required this.count,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The badge overhangs the circle, so it must not be clipped.
      clipBehavior: Clip.none,
      children: [
        _CircleButton(
          onTap: onTap,
          tooltip: tooltip,
          background: AppColors.dark,
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 20,
            color: AppColors.white,
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
