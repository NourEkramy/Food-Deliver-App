import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/restaurant.dart';

/// One restaurant in the home list: photo, name, cuisine, and three facts.
///
/// The design shows a rating, a delivery fee and a delivery time. The API
/// provides none of those, so rather than invent numbers the row shows what is
/// actually known — city, dish count, and whether there is parking.
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(url: restaurant.imageUrl, fallbackIconSize: 40),
            const SizedBox(height: 12),
            Text(
              restaurant.restaurantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              restaurant.type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            // Wrap, not Row: three facts plus a long city name or a large text
            // scale would otherwise overflow.
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _Fact(icon: Icons.place_outlined, label: restaurant.city),
                if (restaurant.dishCount != null)
                  _Fact(
                    icon: Icons.restaurant_menu,
                    label: l10n.dishCount(restaurant.dishCount!),
                  ),
                _Fact(
                  icon: Icons.local_parking,
                  label: restaurant.parkingLot
                      ? l10n.parkingAvailable
                      : l10n.noParking,
                  muted: !restaurant.parkingLot,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a restaurant has no photo, or the network fetch failed.

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool muted;

  const _Fact({required this.icon, required this.label, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.hint : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: muted ? AppColors.hint : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
