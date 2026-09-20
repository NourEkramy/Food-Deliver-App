import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/order.dart';
import '../repository/order_repository.dart';

class OrderDetailState extends Equatable {
  final bool isLoading;
  final Order? order;
  final String? errorMessage;

  /// Distinguishes "loaded, but the server had no such order" from "still
  /// loading", which a null [order] alone cannot.
  final bool isLoaded;

  const OrderDetailState({
    this.isLoading = false,
    this.order,
    this.errorMessage,
    this.isLoaded = false,
  });

  @override
  List<Object?> get props => [isLoading, order, errorMessage, isLoaded];
}

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrderRepository repository;

  OrderDetailCubit(this.repository) : super(const OrderDetailState());

  Future<void> load(String masterId) async {
    emit(const OrderDetailState(isLoading: true));
    try {
      emit(
        OrderDetailState(
          order: await repository.getOrderById(masterId),
          isLoaded: true,
        ),
      );
    } catch (e) {
      emit(
        OrderDetailState(
          isLoaded: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
