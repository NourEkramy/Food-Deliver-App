import 'package:equatable/equatable.dart';

/// Where the app stands on whether someone is signed in.
///
/// [unknown] matters: at launch we have not finished reading the saved session
/// out of secure storage yet. Without it, the app would briefly treat a
/// remembered user as signed out and flash the login screen before correcting
/// itself.
enum AuthStatus { unknown, signedIn, signedOut }

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isLoading;
  final String? apiKey;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.apiKey,
    this.email,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.signedIn && apiKey != null;

  /// Note that [errorMessage] is *cleared* unless you pass a new one. An error
  /// describes one failed attempt, so it should not survive into the next
  /// state — otherwise a stale message lingers under a fresh form.
  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? apiKey,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      apiKey: apiKey ?? this.apiKey,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isLoading, apiKey, email, errorMessage];
}
