import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/restaurant_detail_cubit.dart';
import '../cubit/restaurant_details_state.dart';
import '../model/menu_item.dart';

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
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
          builder: (context, state) {
            if (state is RestaurantDetailLoading ||
                state is RestaurantDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantDetailError) {
              return Center(
                child: Text('Something went wrong: ${state.message}'),
              );
            }

            if (state is RestaurantDetailLoaded) {
              final restaurant = state.restaurant;
              final menuItems = state.menuItems;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text(restaurant.restaurantName),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.type,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.address,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Menu (${menuItems.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _MenuItemCard(item: menuItems[index]),
                        childCount: menuItems.length,
                      ),
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

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : Container(color: Colors.blueGrey.shade100),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '\$${item.itemPrice.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
