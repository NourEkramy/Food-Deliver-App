import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../restaurant_detail/cubit/restaurant_detail_cubit.dart';
import '../../restaurant_detail/repository/restaurant_detail_repository.dart';
import '../../restaurant_detail/view/restaurant_detail_screen.dart';
import '../cubit/restaurant_cubit.dart';
import '../cubit/restaurant_state.dart';
import '../model/restaurant.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  String? selectedType;

  @override
  void initState() {
    super.initState();
    context.read<RestaurantCubit>().loadRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RestaurantCubit, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantLoading || state is RestaurantInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.somethingWentWrong,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          context.read<RestaurantCubit>().loadRestaurants(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is RestaurantLoaded) {
              final types = Restaurant.distinctTypes(state.restaurants);

              final visibleRestaurants = selectedType == null
                  ? state.restaurants
                  : state.restaurants
                        .where((r) => r.type == selectedType)
                        .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.hint,
                        ),
                        hintText: l10n.searchHint,
                        fillColor: AppColors.surfaceGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.allCategories,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CategoryChip(
                          label: l10n.all,
                          selected: selectedType == null,
                          onTap: () => setState(() => selectedType = null),
                        ),
                        ...types.map(
                          (type) => Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8),
                            child: _CategoryChip(
                              label: type,
                              selected: selectedType == type,
                              onTap: () => setState(() => selectedType = type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.openRestaurants,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: visibleRestaurants.length,
                      itemBuilder: (context, index) {
                        return _RestaurantCard(
                          restaurant: visibleRestaurants[index],
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.chipSelected : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.chipSelected : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => RestaurantDetailCubit(
                RestaurantDetailRepository(context.read<ApiClient>().dio),
              ),
              child: RestaurantDetailScreen(
                restaurantId: restaurant.restaurantID,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.restaurantName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(restaurant.type, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              restaurant.address,
              style: const TextStyle(color: AppColors.hint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
