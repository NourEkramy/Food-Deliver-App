class MenuItem {
  final int itemID;
  final String itemName;
  final String itemDescription;
  final String restaurantName;
  final String? imageUrl;
  final double itemPrice;
  final int restaurantID;

  const MenuItem({
    required this.itemID,
    required this.itemDescription,
    required this.itemPrice,
    required this.itemName,
    required this.restaurantName,
    required this.restaurantID,
    this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemID: json["itemID"] as int,
      restaurantID: json["restaurantID"] as int,
      itemDescription: json["itemDescription"] as String,
      itemPrice: (json["itemPrice"] as num).toDouble(),
      itemName: json["itemName"] as String,
      restaurantName: json["restaurantName"] as String,
      imageUrl: json["imageUrl"] as String?,
    );
  }
}
