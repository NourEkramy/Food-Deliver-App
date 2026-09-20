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
        name: session.name,
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

  /// [name] is stored on this device only — the API has no name field. It is
  /// what the home screen greets the user by.
  ///
  /// Unlike [login], this defaults to remembering the session: the designed
  /// sign-up screen has no "Remember me" checkbox, and someone who has just
  /// created an account does not expect the next launch to sign them out.
  Future<void> register(
    String email,
    String password, {
    String name = '',
    bool rememberMe = true,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await repository.register(email, password);
      await _onAuthenticated(
        response.apiKey,
        email,
        name: name,
        rememberMe: rememberMe,
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _message(e)));
    }
  }

  /// Applies a profile change to the live session, and to storage if the user
  /// chose to be remembered.
  ///
  /// The API key is carried through unchanged: nothing in the update response
  /// suggests a new one is issued. If the server does rotate it, the next
  /// request fails with "Invalid API key" and signing in again fixes it.
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    final apiKey = state.apiKey;
    if (apiKey == null) return;

    // Only re-persist if a session was stored in the first place — otherwise
    // this would quietly turn "Remember me" on behind the user's back.
    final stored = await storage.read();
    if (stored != null) {
      await storage.save(Session(apiKey: apiKey, email: email, name: name));
    }

    emit(state.copyWith(email: email, name: name));
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
    String name = '',
  }) async {
    if (rememberMe) {
      await storage.save(Session(apiKey: apiKey, email: email, name: name));
    }

    emit(
      state.copyWith(
        status: AuthStatus.signedIn,
        isLoading: false,
        apiKey: apiKey,
        email: email,
        name: name,
      ),
    );
  }

  /// `Exception.toString()` prefixes the text with "Exception: ", which users
  /// should never see. The repository has already produced a readable
  /// sentence, so we just unwrap it.
  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
