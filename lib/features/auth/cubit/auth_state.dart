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

  /// Collected at sign-up and kept on this device only — the API has no name
  /// field. Empty for anyone who signed in without registering here.
  final String? name;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.apiKey,
    this.email,
    this.name,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.signedIn && apiKey != null;

  /// What to call the user on the home screen.
  ///
  /// Falls back to the part of the email before the @, so someone who signed in
  /// on a new device is greeted by something recognisable rather than a blank.
  String get displayName {
    final n = name?.trim() ?? '';
    if (n.isNotEmpty) return n;

    final local = email?.split('@').first ?? '';
    return local.isNotEmpty ? local : 'there';
  }

  /// Note that [errorMessage] is *cleared* unless you pass a new one. An error
  /// describes one failed attempt, so it should not survive into the next
  /// state — otherwise a stale message lingers under a fresh form.
  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? apiKey,
    String? email,
    String? name,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      apiKey: apiKey ?? this.apiKey,
      email: email ?? this.email,
      name: name ?? this.name,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isLoading,
    apiKey,
    email,
    name,
    errorMessage,
  ];
}
