class Restaurant {
  final int restaurantID;
  final String restaurantName;
  final String address;
  final String type;
  final bool parkingLot;

  /// Filled in by the repository, not by [fromJson].
  ///
  /// `/Restaurant` returns no image at all, so the list screen borrows a photo
  /// from one of the restaurant's menu items. Null until that merge happens —
  /// e.g. on the detail screen, which fetches a restaurant on its own.
  final String? imageUrl;

  /// How many menu items this restaurant has. Also merged in, also null until
  /// the repository has the menu data to count.
  final int? dishCount;

  const Restaurant({
    required this.restaurantID,
    required this.address,
    required this.parkingLot,
    required this.restaurantName,
    required this.type,
    this.imageUrl,
    this.dishCount,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantID: json["restaurantID"] as int,
      address: json["address"] as String,
      parkingLot: json["parkingLot"] as bool,
      restaurantName: json["restaurantName"] as String,
      type: json["type"] as String,
    );
  }

  /// The city, for the card's location line.
  ///
  /// Addresses arrive as "Jaipur, Amber Fort, Rajasthan" — city first, then
  /// area, then state. Falls back to the whole string if that shape ever
  /// changes, so the card degrades to something readable rather than empty.
  String get city {
    final first = address.split(',').first.trim();
    return first.isEmpty ? address : first;
  }

  Restaurant copyWith({String? imageUrl, int? dishCount}) {
    return Restaurant(
      restaurantID: restaurantID,
      address: address,
      parkingLot: parkingLot,
      restaurantName: restaurantName,
      type: type,
      imageUrl: imageUrl ?? this.imageUrl,
      dishCount: dishCount ?? this.dishCount,
    );
  }

  static List<String> distinctTypes(List<Restaurant> restaurants) {
    return restaurants.map((r) => r.type).toSet().toList()..sort();
  }
}
