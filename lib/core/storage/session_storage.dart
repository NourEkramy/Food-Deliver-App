import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A signed-in user's saved credentials.
///
/// [name] is ours, not the server's: `/User/register` accepts only an email and
/// a password, so the name the sign-up form collects lives only on this device.
/// It exists to feed the home screen's greeting, which otherwise has nothing to
/// address the user by. It is empty for anyone who signed in rather than
/// registered on this device.
class Session {
  final String apiKey;
  final String email;
  final String name;

  const Session({required this.apiKey, required this.email, this.name = ''});
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
  static const _nameKey = 'session_name';

  final FlutterSecureStorage _storage;

  const SecureSessionStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<Session?> read() async {
    final apiKey = await _storage.read(key: _apiKeyKey);
    final email = await _storage.read(key: _emailKey);
    final name = await _storage.read(key: _nameKey);

    // The API key is what makes a session usable; email and name are extras.
    if (apiKey == null || apiKey.isEmpty) return null;
    return Session(apiKey: apiKey, email: email ?? '', name: name ?? '');
  }

  @override
  Future<void> save(Session session) async {
    await _storage.write(key: _apiKeyKey, value: session.apiKey);
    await _storage.write(key: _emailKey, value: session.email);
    await _storage.write(key: _nameKey, value: session.name);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _apiKeyKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _nameKey);
  }
}
