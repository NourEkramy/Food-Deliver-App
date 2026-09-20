import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_store.dart';
import '../model/payment_method.dart';

class PaymentState extends Equatable {
  final List<PaymentMethod> cards;
  final String selectedId;

  const PaymentState({this.cards = const [], this.selectedId = 'cash'});

  /// Cash is always available, so it heads the list rather than being stored.
  List<PaymentMethod> get all => [PaymentMethod.cash, ...cards];

  PaymentMethod get selected {
    for (final method in all) {
      if (method.id == selectedId) return method;
    }
    return PaymentMethod.cash;
  }

  PaymentState copyWith({List<PaymentMethod>? cards, String? selectedId}) =>
      PaymentState(
        cards: cards ?? this.cards,
        selectedId: selectedId ?? this.selectedId,
      );

  @override
  List<Object?> get props => [cards, selectedId];
}

class PaymentCubit extends Cubit<PaymentState> {
  final LocalStore store;

  PaymentCubit([this.store = const LocalStore()]) : super(const PaymentState());

  Future<void> load() async {
    final rows = await store.readList(LocalStore.keyCards);
    emit(
      state.copyWith(
        cards: rows
            .map(PaymentMethod.tryParse)
            .whereType<PaymentMethod>()
            .toList(),
      ),
    );
  }

  /// Saves a card, keeping only its brand and last four digits.
  Future<void> addCard({
    required String cardNumber,
    required String holder,
  }) async {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final card = PaymentMethod(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: PaymentKind.card,
      brand: PaymentMethod.brandOf(digits),
      // The rest of the number is never stored, and never leaves this method.
      last4: digits.length >= 4 ? digits.substring(digits.length - 4) : digits,
      holder: holder,
    );

    final cards = [...state.cards, card];
    await store.writeList(
      LocalStore.keyCards,
      cards.map((c) => c.toJson()).toList(),
    );
    emit(state.copyWith(cards: cards, selectedId: card.id));
  }

  Future<void> removeCard(String id) async {
    final cards = state.cards.where((c) => c.id != id).toList();
    await store.writeList(
      LocalStore.keyCards,
      cards.map((c) => c.toJson()).toList(),
    );
    emit(
      PaymentState(
        cards: cards,
        selectedId: state.selectedId == id ? 'cash' : state.selectedId,
      ),
    );
  }

  void select(String id) => emit(state.copyWith(selectedId: id));
}
