import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../repository/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  /// The profile belongs to the signed-in user, so saving has to update the
  /// session too — otherwise the app would keep greeting them by the old name
  /// and remember the old email.
  final AuthCubit authCubit;

  ProfileCubit(this.repository, this.authCubit) : super(const ProfileState());

  Future<void> save({
    required String name,
    required String email,
    required String newPassword,
  }) async {
    final apiKey = authCubit.state.apiKey;
    if (apiKey == null || state.isSaving) return;

    emit(state.copyWith(isSaving: true));

    try {
      await repository.updateProfile(
        apiKey: apiKey,
        email: email,
        newPassword: newPassword,
      );

      // The name never reaches the server — it has no field for one — so it is
      // saved alongside the session on this device.
      await authCubit.updateProfile(name: name, email: email);

      emit(const ProfileState(justSaved: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
