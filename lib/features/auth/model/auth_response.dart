class AuthResponse {
  final String userEmail;
  final String apiKey;

  const AuthResponse({required this.userEmail, required this.apiKey});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userEmail: json['userEmail'] as String,
      apiKey: json['usercode'] as String,
    );
  }
}