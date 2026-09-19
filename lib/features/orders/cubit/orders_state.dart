import 'package:equatable/equatable.dart';

import '../model/order.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  /// The order currently being cancelled, so only that row shows a spinner
  /// rather than the whole list reloading.
  final String? cancellingId;

  const OrdersLoaded(this.orders, {this.cancellingId});

  OrdersLoaded copyWith({List<Order>? orders, String? cancellingId}) =>
      OrdersLoaded(orders ?? this.orders, cancellingId: cancellingId);

  @override
  List<Object?> get props => [orders, cancellingId];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
