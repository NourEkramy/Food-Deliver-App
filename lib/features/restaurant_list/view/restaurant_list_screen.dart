import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
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
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RestaurantCubit, RestaurantState>(
          builder: (context, state) {
            if (state is RestaurantLoading || state is RestaurantInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RestaurantError) {
              return Center(child: Text('Something went wrong: ${state.message}'));
            }

            if (state is RestaurantLoaded) {
              final types = Restaurant.distinctTypes(state.restaurants);

              final visibleRestaurants = selectedType == null
                  ? state.restaurants
                  : state.restaurants.where((r) => r.type == selectedType).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search dishes, restaurants',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('All Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CategoryChip(
                          label: 'All',
                          selected: selectedType == null,
                          onTap: () => setState(() => selectedType = null),
                        ),
                        ...types.map((type) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _CategoryChip(
                            label: type,
                            selected: selectedType == type,
                            onTap: () => setState(() => selectedType = type),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Open Restaurants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: visibleRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = visibleRestaurants[index];
                        return _RestaurantCard(restaurant: restaurant);
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

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? Colors.orange : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
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
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => RestaurantDetailCubit(
              RestaurantDetailRepository(context.read<ApiClient>().dio),
            ),
            child: RestaurantDetailScreen(restaurantId: restaurant.restaurantID),
          ),
        ));
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
                color: Colors.blueGrey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 8),
            Text(restaurant.restaurantName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(restaurant.type, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(restaurant.address, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}