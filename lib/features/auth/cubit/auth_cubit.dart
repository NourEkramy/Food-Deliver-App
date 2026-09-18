import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/session_storage.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SessionStorage storage;

  AuthCubit(this.repository, this.storage) : super(const AuthState());

  /// Called once at launch. Moves the app out of [AuthStatus.unknown] by
  /// reporting whether a saved session exists.
  Future<void> restoreSession() async {
    final session = await storage.read();

    if (session == null) {
      emit(state.copyWith(status: AuthStatus.signedOut));
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.signedIn,
        apiKey: session.apiKey,
        email: session.email,
      ),
    );
  }

  /// [rememberMe] decides whether the API key outlives this app run. When
  /// false the key stays in memory only, so closing the app signs the user out.
  Future<void> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await repository.login(email, password);
      await _onAuthenticated(response.apiKey, email, rememberMe: rememberMe);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _message(e)));
    }
  }

  Future<void> register(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await repository.register(email, password);
      await _onAuthenticated(response.apiKey, email, rememberMe: rememberMe);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _message(e)));
    }
  }

  /// Drops the API key from memory *and* from storage, so a remembered session
  /// does not quietly sign the user back in on the next launch.
  Future<void> logout() async {
    await storage.clear();
    emit(const AuthState(status: AuthStatus.signedOut));
  }

  Future<void> _onAuthenticated(
    String apiKey,
    String email, {
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await storage.save(Session(apiKey: apiKey, email: email));
    }

    emit(
      state.copyWith(
        status: AuthStatus.signedIn,
        isLoading: false,
        apiKey: apiKey,
        email: email,
      ),
    );
  }

  /// `Exception.toString()` prefixes the text with "Exception: ", which users
  /// should never see. The repository has already produced a readable
  /// sentence, so we just unwrap it.
  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
