import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/local_store.dart';

/// The language the app is displayed in.
///
/// A null [Locale] means "follow the device", which is the default and what
/// most users want. Choosing one explicitly overrides that and is remembered.
class LocaleCubit extends Cubit<Locale?> {
  final LocalStore store;

  LocaleCubit([this.store = const LocalStore()]) : super(null);

  Future<void> load() async {
    final code = await store.readString(LocalStore.keyLocale);
    if (code != null) emit(Locale(code));
  }

  /// Pass null to go back to following the device setting.
  Future<void> select(Locale? locale) async {
    await store.writeString(LocalStore.keyLocale, locale?.languageCode);
    emit(locale);
  }
}
