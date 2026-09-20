import 'package:flutter/material.dart';

import '../../../core/widgets/app_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cart_badge_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/view/add_to_cart.dart';
import '../cubit/restaurant_detail_cubit.dart';
import '../cubit/restaurant_details_state.dart';
import '../model/menu_item.dart';
import '../repository/restaurant_detail_repository.dart';
import 'widgets/menu_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantDetailCubit>().loadRestaurantDetail(
      widget.restaurantId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.restaurantView,
              trailing: CartBadgeButton(
                onTap: () => AppRoutes.openCart(context),
              ),
            ),
            Expanded(
              child: BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
                builder: (context, state) {
                  if (state is RestaurantDetailError) {
                    return _Error(
                      message: state.message,
                      onRetry: () => context
                          .read<RestaurantDetailCubit>()
                          .loadRestaurantDetail(widget.restaurantId),
                    );
                  }

                  if (state is! RestaurantDetailLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return _Body(state: state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RestaurantDetailLoaded state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final restaurant = state.restaurant;

    // /Restaurant carries no image, so the first dish's photo stands in for the
    // restaurant — the same trick the home list uses.
    final heroUrl = state.menuItems
        .map((item) => item.imageUrl)
        .whereType<String>()
        .firstOrNull;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AppNetworkImage(url: heroUrl, fallbackIconSize: 40),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.restaurantName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Same honest substitution as the home card: the design's
                // rating / fee / time have no source, these three do.
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _Fact(icon: Icons.place_outlined, label: restaurant.city),
                    _Fact(
                      icon: Icons.restaurant_menu,
                      label: l10n.dishCount(state.menuItems.length),
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
        ),
        SliverToBoxAdapter(child: _SortBar(state: state)),
        if (state.menuItems.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  l10n.dishCount(0),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: state.menuItems.length,
              itemBuilder: (context, index) {
                final item = state.menuItems[index];
                return _MenuTile(item: item);
              },
            ),
          ),
      ],
    );
  }
}

/// Split out so only this tile rebuilds when its own cart count changes.
class _MenuTile extends StatelessWidget {
  final MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final inCart = context.select<CartCubit, int>(
      (cubit) => cubit.state.quantityOf(item.itemID),
    );

    return MenuItemCard(
      item: item,
      inCart: inCart,
      onTap: () => AppRoutes.openFoodDetails(context, item),
      onAdd: () => addToCart(context, item),
    );
  }
}

/// The design puts dish-category chips here (Burger, Sandwich, Pizza). The API
/// has no dish categories, but it does have `?sortbyprice=`, so the slot earns
/// its place with a control that actually does something.
class _SortBar extends StatelessWidget {
  final RestaurantDetailLoaded state;

  const _SortBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RestaurantDetailCubit>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.menuSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (state.isSorting)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          PopupMenuButton<MenuSort?>(
            tooltip: l10n.sortByPrice,
            initialValue: state.sort,
            onSelected: cubit.sortMenu,
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(l10n.menuSection)),
              PopupMenuItem(
                value: MenuSort.priceAscending,
                child: Text(l10n.priceLowToHigh),
              ),
              PopupMenuItem(
                value: MenuSort.priceDescending,
                child: Text(l10n.priceHighToLow),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.sortByPrice,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Error({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 44, color: AppColors.hint),
          const SizedBox(height: 16),
          Text(
            l10n.somethingWentWrong,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
