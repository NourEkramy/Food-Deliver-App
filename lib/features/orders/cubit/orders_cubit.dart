import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/order_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository repository;

  OrdersCubit(this.repository) : super(OrdersInitial());

  Future<void> load() async {
    emit(OrdersLoading());
    try {
      emit(OrdersLoaded(await repository.getOrders()));
    } catch (e) {
      emit(OrdersError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Cancels one order and drops it from the list.
  ///
  /// The row is removed locally rather than by reloading, so the list does not
  /// flash back to a spinner for a change we already know the result of.
  Future<void> cancel(String orderId) async {
    final current = state;
    if (current is! OrdersLoaded || current.cancellingId != null) return;

    emit(current.copyWith(cancellingId: orderId));
    try {
      await repository.cancelOrder(orderId);
      emit(OrdersLoaded(current.orders.where((o) => o.id != orderId).toList()));
    } catch (e) {
      emit(OrdersError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
