import 'package:equatable/equatable.dart';

/// One line of an order: a dish and how many were ordered.
class OrderLine extends Equatable {
  final String itemName;
  final int quantity;
  final double? price;

  const OrderLine({required this.itemName, required this.quantity, this.price});

  @override
  List<Object?> get props => [itemName, quantity, price];
}

/// A placed order.
///
/// Parsed tolerantly on purpose. `/Order` needs an API key, so its exact
/// response shape could not be inspected while this was written — only the
/// endpoint list. Every field except the id is optional and several spellings
/// are accepted, so an unexpected shape degrades to a sparser card rather than
/// throwing a TypeError the user would see as raw Dart.
class Order extends Equatable {
  final String id;
  final String? restaurantName;
  final int? restaurantId;
  final double? total;
  final DateTime? placedAt;
  final List<OrderLine> lines;

  const Order({
    required this.id,
    this.restaurantName,
    this.restaurantId,
    this.total,
    this.placedAt,
    this.lines = const [],
  });

  /// How many dishes the order contains, summed across its lines.
  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  /// Returns null when the payload carries nothing that identifies an order,
  /// so the caller can skip the row instead of showing a blank card.
  static Order? tryParse(Object? data) {
    if (data is! Map) return null;

    final id = _firstString(data, const [
      'masterID',
      'masterId',
      'master_id',
      'orderID',
      'orderId',
      'id',
    ]);
    if (id == null) return null;

    return Order(
      id: id,
      restaurantName: _firstString(data, const [
        'restaurantName',
        'restaurant',
      ]),
      restaurantId: _firstInt(data, const ['restaurantID', 'restaurantId']),
      total: _firstDouble(data, const [
        'total',
        'totalPrice',
        'orderTotal',
        'amount',
      ]),
      placedAt: _firstDate(data, const [
        'orderDate',
        'createdAt',
        'date',
        'orderedOn',
      ]),
      lines: _parseLines(data),
    );
  }

  static List<OrderLine> _parseLines(Map data) {
    final raw =
        data['menuDTO'] ??
        data['items'] ??
        data['orderDetails'] ??
        data['orderItems'] ??
        data['menu'];
    if (raw is! List) return const [];

    final lines = <OrderLine>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final name = _firstString(entry, const ['itemName', 'name', 'item']);
      if (name == null) continue;

      lines.add(
        OrderLine(
          itemName: name,
          quantity: _firstInt(entry, const ['quantity', 'qty', 'count']) ?? 1,
          price: _firstDouble(entry, const ['itemPrice', 'price', 'total']),
        ),
      );
    }
    return lines;
  }

  static String? _firstString(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
      // Ids often arrive as numbers.
      if (value is num) return value.toString();
    }
    return null;
  }

  static int? _firstInt(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? _firstDouble(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static DateTime? _firstDate(Map data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    restaurantName,
    restaurantId,
    total,
    placedAt,
    lines,
  ];
}
