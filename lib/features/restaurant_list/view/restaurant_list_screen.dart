import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_state.dart';
import '../model/restaurant.dart';
import 'widgets/app_drawer.dart';
import 'widgets/category_chip.dart';
import 'widgets/home_header.dart';
import 'widgets/restaurant_card.dart';

/// The home screen (`Home V.1` in the design).
///
/// Named for the feature folder it lives in rather than the design, since the
/// whole restaurant_list feature is built around it.
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final _searchController = TextEditingController();
  String? _selectedType;
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<RestaurantCubit>().loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies the category chip and the search box together.
  ///
  /// Both run on the already-downloaded list. With ~30 restaurants that is
  /// instant, where a request per keystroke would not be.
  List<Restaurant> _visible(List<Restaurant> all) {
    final query = _query.trim().toLowerCase();

    return all.where((r) {
      if (_selectedType != null && r.type != _selectedType) return false;
      if (query.isEmpty) return true;
      return r.restaurantName.toLowerCase().contains(query) ||
          r.type.toLowerCase().contains(query) ||
          r.address.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              // Builder so `Scaffold.of` sees this Scaffold rather than
              // searching above it and finding nothing.
              child: Builder(
                builder: (context) => HomeHeader(
                  onMenuTap: () => Scaffold.of(context).openDrawer(),
                  onCartTap: () => AppRoutes.openCart(context),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _Greeting()),
            SliverToBoxAdapter(child: _searchField(l10n)),
            ..._contentSlivers(l10n),
          ],
        ),
      ),
    );
  }

  Widget _searchField(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.hint),
          hintText: l10n.searchHint,
          fillColor: AppColors.surfaceGrey,
          suffixIcon: _query.isEmpty
              ? IconButton(
                  tooltip: l10n.search,
                  icon: const Icon(Icons.tune, size: 20),
                  color: AppColors.hint,
                  onPressed: () => AppRoutes.openSearch(context),
                )
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.hint,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  /// The part of the page that depends on what the Cubit has loaded.
  List<Widget> _contentSlivers(AppLocalizations l10n) {
    final state = context.watch<RestaurantCubit>().state;

    if (state is RestaurantLoading || state is RestaurantInitial) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state is RestaurantError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _ErrorState(
            message: state.message,
            onRetry: () => context.read<RestaurantCubit>().loadRestaurants(),
          ),
        ),
      ];
    }

    if (state is! RestaurantLoaded) return const [];

    final types = Restaurant.distinctTypes(state.restaurants);
    final visible = _visible(state.restaurants);

    return [
      SliverToBoxAdapter(child: _SectionHeader(title: l10n.allCategories)),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              CategoryChip(
                label: l10n.all,
                selected: _selectedType == null,
                onTap: () => setState(() => _selectedType = null),
              ),
              ...types.map(
                (type) => CategoryChip(
                  label: type,
                  selected: _selectedType == type,
                  onTap: () => setState(() => _selectedType = type),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(child: _SectionHeader(title: l10n.openRestaurants)),
      if (visible.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Center(
              child: Text(
                l10n.noRestaurants,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
          sliver: SliverList.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) => RestaurantCard(
              restaurant: visible[index],
              onTap: () => AppRoutes.openRestaurant(
                context,
                visible[index].restaurantID,
              ),
            ),
          ),
        ),
    ];
  }
}

/// "Hey Nour, Good Afternoon!" — the name comes from the session, which is why
/// the sign-up screen collects one the API has no field for.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = context.select<AuthCubit, String>(
      (cubit) => cubit.state.displayName,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Text.rich(
        TextSpan(
          text: l10n.greeting(name),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          TextButton(
            // Wired up when the dedicated listing screens exist.
            onPressed: null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.seeAll,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
