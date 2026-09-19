import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cart_badge_button.dart';
import '../../../../l10n/app_localizations.dart';

/// The top row of the home screen: menu button, delivery address, cart.
///
/// The address is a placeholder because no address endpoint exists. It reads
/// "Set delivery address" rather than inventing a location, so the screen never
/// claims to know something it does not.
class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;

  const HomeHeader({
    super.key,
    required this.onMenuTap,
    required this.onCartTap,
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
          CartBadgeButton(onTap: onCartTap),
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
