import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? apiKey;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.apiKey, this.errorMessage});

  bool get isAuthenticated => apiKey != null;

  AuthState copyWith({bool? isLoading, String? apiKey, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      apiKey: apiKey ?? this.apiKey,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, apiKey, errorMessage];
}