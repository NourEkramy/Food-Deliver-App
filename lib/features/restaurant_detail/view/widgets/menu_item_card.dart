import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/money.dart';
import '../../model/menu_item.dart';

/// One dish in the restaurant's menu grid.
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  /// How many of this dish are already in the cart. Shown as a badge so the
  /// user can see what they have added without opening the cart.
  final int inCart;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
    this.inCart = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _Thumbnail(url: item.imageUrl),
                      ),
                    ),
                    if (inCart > 0)
                      PositionedDirectional(
                        top: 6,
                        end: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$inCart',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.restaurantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatPrice(context, item.itemPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAdd,
                      child: const SizedBox(
                        height: 32,
                        width: 32,
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;

  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) return const _ThumbnailFallback();

    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ColoredBox(color: AppColors.surfaceGrey),
      errorBuilder: (context, error, stack) => const _ThumbnailFallback(),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceGrey,
      child: Center(
        child: Icon(Icons.restaurant, color: AppColors.hint, size: 28),
      ),
    );
  }
}
