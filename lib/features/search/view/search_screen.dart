import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/util/money.dart';
import '../../../core/widgets/cart_badge_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes.dart';
import '../../cart/view/add_to_cart.dart';
import '../../restaurant_detail/model/menu_item.dart';
import '../../restaurant_detail/repository/restaurant_detail_repository.dart';
import '../../restaurant_list/model/restaurant.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

/// Searches dishes and restaurants at once.
///
/// This is also where the design's separate Filter screen lives: the only
/// filter the API offers is `sortbyprice`, which is one control rather than a
/// page of its own.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.search,
              trailing: CartBadgeButton(
                onTap: () => AppRoutes.openCart(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: cubit.queryChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: AppColors.hint),
                  hintText: l10n.searchHint,
                  fillColor: AppColors.surfaceGrey,
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: AppColors.hint,
                          onPressed: () {
                            _controller.clear();
                            cubit.queryChanged('');
                          },
                        ),
                ),
              ),
            ),
            const _SortRow(),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => _Results(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SearchCubit>();
    final sort = context.select<SearchCubit, MenuSort?>((c) => c.state.sort);

    Widget chip(String label, MenuSort? value) {
      final selected = sort == value;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => cubit.sortChanged(value),
          selectedColor: AppColors.chipSelected,
          backgroundColor: AppColors.surfaceGrey,
          side: BorderSide.none,
          labelStyle: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          chip(l10n.all, null),
          chip(l10n.priceLowToHigh, MenuSort.priceAscending),
          chip(l10n.priceHighToLow, MenuSort.priceDescending),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final SearchState state;

  const _Results({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.isLoading && state.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _Message(icon: Icons.cloud_off, text: state.errorMessage!);
    }

    if (!state.hasSearched) {
      return _Message(icon: Icons.search, text: l10n.searchPrompt);
    }

    if (state.isEmpty) {
      return _Message(icon: Icons.sentiment_dissatisfied, text: l10n.noResults);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        if (state.restaurants.isNotEmpty) ...[
          _SectionLabel(
            text: '${l10n.searchRestaurants} (${state.restaurants.length})',
          ),
          ...state.restaurants.map((r) => _RestaurantRow(restaurant: r)),
          const SizedBox(height: 16),
        ],
        if (state.dishes.isNotEmpty) ...[
          _SectionLabel(text: '${l10n.searchDishes} (${state.dishes.length})'),
          ...state.dishes.map((d) => _DishRow(item: d)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantRow({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.surfaceGrey,
        child: Icon(Icons.storefront, color: AppColors.hint, size: 20),
      ),
      title: Text(
        restaurant.restaurantName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${restaurant.type} · ${restaurant.city}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      onTap: () => AppRoutes.openRestaurant(context, restaurant.restaurantID),
    );
  }
}

class _DishRow extends StatelessWidget {
  final MenuItem item;

  const _DishRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 48,
          width: 48,
          child: item.imageUrl == null
              ? const ColoredBox(
                  color: AppColors.surfaceGrey,
                  child: Icon(
                    Icons.restaurant,
                    size: 20,
                    color: AppColors.hint,
                  ),
                )
              : Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.surfaceGrey),
                ),
        ),
      ),
      title: Text(
        item.itemName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${item.restaurantName} · ${formatPrice(context, item.itemPrice)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle, color: AppColors.primary),
        onPressed: () => addToCart(context, item),
      ),
      onTap: () => AppRoutes.openFoodDetails(context, item),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.hint),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
