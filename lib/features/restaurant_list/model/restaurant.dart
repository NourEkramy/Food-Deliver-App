class Restaurant {
  final int restaurantID;
  final String restaurantName;
  final String address;
  final String type;
  final bool parkingLot;

  const Restaurant({
    required this.restaurantID,
    required this.address,
    required this.parkingLot,
    required this.restaurantName,
    required this.type,
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

  static List<String> distinctTypes(List<Restaurant> restaurants) {
    return restaurants.map((r) => r.type).toSet().toList();
  }
}
