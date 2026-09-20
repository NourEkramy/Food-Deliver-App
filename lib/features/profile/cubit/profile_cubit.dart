import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../repository/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  /// The profile belongs to the signed-in user, so changes have to reach the
  /// session too — otherwise the app would keep greeting them by the old name.
  final AuthCubit authCubit;

  ProfileCubit(this.repository, this.authCubit) : super(const ProfileState());

  /// Saves the display name.
  ///
  /// No network call: the API has no name field, and no way to change an email
  /// either. Everything this screen edits lives on the device.
  Future<void> saveName(String name) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    await authCubit.updateProfile(name: name);

    emit(const ProfileState(outcome: ProfileOutcome.nameSaved));
  }

  /// The one profile field the server actually stores.
  Future<void> changePassword(String newPassword) async {
    final apiKey = authCubit.state.apiKey;
    if (apiKey == null || state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    try {
      await repository.changePassword(apiKey: apiKey, newPassword: newPassword);
      emit(const ProfileState(outcome: ProfileOutcome.passwordChanged));
    } catch (e) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Deletes the account, then signs out.
  ///
  /// The sign-out is not optional tidying: the API key now refers to a user
  /// that no longer exists, so every later request would fail.
  Future<void> deleteAccount() async {
    final apiKey = authCubit.state.apiKey;
    if (apiKey == null || state.isBusy) return;

    emit(state.copyWith(isBusy: true));
    try {
      await repository.deleteAccount(apiKey);
      emit(const ProfileState(outcome: ProfileOutcome.accountDeleted));
      await authCubit.logout();
    } catch (e) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
