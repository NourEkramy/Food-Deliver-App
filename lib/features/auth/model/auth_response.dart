class AuthResponse {
  final String userEmail;
  final String apiKey;

  const AuthResponse({required this.userEmail, required this.apiKey});

  /// Reads an auth payload, returning null when it carries no user code.
  ///
  /// Null is a real outcome rather than an error: `/User/register` may well
  /// acknowledge a new account without handing back credentials, and the
  /// caller can recover from that by logging in. A blind `as String` cast here
  /// would instead throw a TypeError that bypasses the repository's DioException
  /// handling and reaches the user as raw Dart jargon.
  static AuthResponse? tryParse(Object? data, {String? fallbackEmail}) {
    if (data is! Map) return null;

    final code = data['usercode'] ?? data['userCode'] ?? data['apiKey'];
    if (code is! String || code.isEmpty) return null;

    final email = data['userEmail'] ?? data['useremail'] ?? fallbackEmail;
    return AuthResponse(userEmail: email is String ? email : '', apiKey: code);
  }
}
