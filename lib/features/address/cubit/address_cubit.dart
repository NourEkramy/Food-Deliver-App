import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_store.dart';
import '../model/address.dart';

class AddressState extends Equatable {
  final List<Address> addresses;
  final String? selectedId;
  final bool isLoaded;

  const AddressState({
    this.addresses = const [],
    this.selectedId,
    this.isLoaded = false,
  });

  /// The address the cart should deliver to.
  ///
  /// Falls back to the first saved one, so a user who never explicitly chose
  /// still sees an address rather than a prompt.
  Address? get selected {
    if (addresses.isEmpty) return null;
    for (final address in addresses) {
      if (address.id == selectedId) return address;
    }
    return addresses.first;
  }

  AddressState copyWith({
    List<Address>? addresses,
    String? selectedId,
    bool? isLoaded,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedId: selectedId ?? this.selectedId,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [addresses, selectedId, isLoaded];
}

class AddressCubit extends Cubit<AddressState> {
  final LocalStore store;

  AddressCubit([this.store = const LocalStore()]) : super(const AddressState());

  Future<void> load() async {
    final rows = await store.readList(LocalStore.keyAddresses);
    emit(
      state.copyWith(
        addresses: rows.map(Address.tryParse).whereType<Address>().toList(),
        isLoaded: true,
      ),
    );
  }

  Future<void> add(Address address) async {
    final addresses = [...state.addresses, address];
    await _persist(addresses);
    // A newly added address becomes the selected one: adding it is itself a
    // statement of intent to use it.
    emit(state.copyWith(addresses: addresses, selectedId: address.id));
  }

  Future<void> remove(String id) async {
    final addresses = state.addresses.where((a) => a.id != id).toList();
    await _persist(addresses);
    emit(
      AddressState(
        addresses: addresses,
        selectedId: state.selectedId == id ? null : state.selectedId,
        isLoaded: true,
      ),
    );
  }

  void select(String id) => emit(state.copyWith(selectedId: id));

  Future<void> _persist(List<Address> addresses) => store.writeList(
    LocalStore.keyAddresses,
    addresses.map((a) => a.toJson()).toList(),
  );
}
