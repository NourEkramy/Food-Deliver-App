import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A signed-in user's saved credentials.
class Session {
  final String apiKey;
  final String email;

  const Session({required this.apiKey, required this.email});
}

/// What the app needs from persistent storage to remember a signed-in user.
///
/// [AuthCubit] depends on this interface rather than on flutter_secure_storage
/// directly. That keeps the Cubit testable — a test can pass an in-memory fake
/// instead of touching the real Keystore — and means swapping the backing store
/// later is a one-file change.
abstract class SessionStorage {
  Future<Session?> read();
  Future<void> save(Session session);
  Future<void> clear();
}

/// Stores the session in the platform's encrypted store: the Android Keystore
/// or the iOS Keychain.
///
/// An API key is a credential — anyone holding it can act as the user — so it
/// does not belong in SharedPreferences, which is plain text that any process
/// with file access can read on a rooted device.
class SecureSessionStorage implements SessionStorage {
  static const _apiKeyKey = 'session_api_key';
  static const _emailKey = 'session_email';

  final FlutterSecureStorage _storage;

  const SecureSessionStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<Session?> read() async {
    final apiKey = await _storage.read(key: _apiKeyKey);
    final email = await _storage.read(key: _emailKey);

    if (apiKey == null || apiKey.isEmpty) return null;
    return Session(apiKey: apiKey, email: email ?? '');
  }

  @override
  Future<void> save(Session session) async {
    await _storage.write(key: _apiKeyKey, value: session.apiKey);
    await _storage.write(key: _emailKey, value: session.email);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _apiKeyKey);
    await _storage.delete(key: _emailKey);
  }
}
