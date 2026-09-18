import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/storage/session_storage.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:food_delivery/features/auth/cubit/auth_state.dart';
import 'package:food_delivery/features/auth/model/auth_response.dart';
import 'package:food_delivery/features/auth/repository/auth_repository.dart';

/// Keeps the session in a plain field instead of the platform Keystore, so
/// these tests run on the Dart VM with no device attached.
class FakeSessionStorage implements SessionStorage {
  Session? _saved;
  int clearCount = 0;

  FakeSessionStorage([this._saved]);

  Session? get saved => _saved;

  @override
  Future<Session?> read() async => _saved;

  @override
  Future<void> save(Session session) async => _saved = session;

  @override
  Future<void> clear() async {
    _saved = null;
    clearCount++;
  }
}

class FakeAuthRepository extends AuthRepository {
  final String? apiKey;
  final String? failWith;

  FakeAuthRepository({this.apiKey, this.failWith}) : super(Dio());

  @override
  Future<AuthResponse> login(String email, String password) async {
    if (failWith != null) throw Exception(failWith);
    return AuthResponse(userEmail: email, apiKey: apiKey!);
  }

  @override
  Future<AuthResponse> register(String email, String password) async =>
      login(email, password);
}

void main() {
  group('restoreSession', () {
    test('reports signedOut when nothing is stored', () async {
      final cubit = AuthCubit(FakeAuthRepository(), FakeSessionStorage());

      expect(cubit.state.status, AuthStatus.unknown);
      await cubit.restoreSession();

      expect(cubit.state.status, AuthStatus.signedOut);
      expect(cubit.state.isAuthenticated, isFalse);
    });

    test('signs in from a stored session', () async {
      final storage = FakeSessionStorage(
        const Session(apiKey: 'stored-key', email: 'nour@example.com'),
      );
      final cubit = AuthCubit(FakeAuthRepository(), storage);

      await cubit.restoreSession();

      expect(cubit.state.status, AuthStatus.signedIn);
      expect(cubit.state.isAuthenticated, isTrue);
      expect(cubit.state.apiKey, 'stored-key');
      expect(cubit.state.email, 'nour@example.com');
    });
  });

  group('login', () {
    test('persists the key when rememberMe is true', () async {
      final storage = FakeSessionStorage();
      final cubit = AuthCubit(FakeAuthRepository(apiKey: 'abc123'), storage);

      await cubit.login('nour@example.com', 'secret', rememberMe: true);

      expect(cubit.state.isAuthenticated, isTrue);
      expect(storage.saved?.apiKey, 'abc123');
    });

    test('keeps the key in memory only when rememberMe is false', () async {
      final storage = FakeSessionStorage();
      final cubit = AuthCubit(FakeAuthRepository(apiKey: 'abc123'), storage);

      await cubit.login('nour@example.com', 'secret', rememberMe: false);

      expect(cubit.state.isAuthenticated, isTrue);
      expect(storage.saved, isNull, reason: 'nothing should reach storage');
    });

    test('surfaces the error message without the Exception prefix', () async {
      final cubit = AuthCubit(
        FakeAuthRepository(failWith: 'Invalid Details'),
        FakeSessionStorage(),
      );

      await cubit.login('nour@example.com', 'wrong');

      expect(cubit.state.errorMessage, 'Invalid Details');
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isAuthenticated, isFalse);
    });

    test('clears a previous error on the next attempt', () async {
      final cubit = AuthCubit(
        FakeAuthRepository(failWith: 'Invalid Details'),
        FakeSessionStorage(),
      );

      await cubit.login('nour@example.com', 'wrong');
      expect(cubit.state.errorMessage, isNotNull);

      // A fresh attempt starts by setting isLoading, which must not carry the
      // stale message along with it.
      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);
      await cubit.login('nour@example.com', 'wrong');
      await sub.cancel();

      expect(states.first.isLoading, isTrue);
      expect(states.first.errorMessage, isNull);
    });
  });

  test('logout wipes storage so the next launch is signed out', () async {
    final storage = FakeSessionStorage(
      const Session(apiKey: 'stored-key', email: 'nour@example.com'),
    );
    final cubit = AuthCubit(FakeAuthRepository(), storage);
    await cubit.restoreSession();
    expect(cubit.state.isAuthenticated, isTrue);

    await cubit.logout();

    expect(cubit.state.status, AuthStatus.signedOut);
    expect(cubit.state.apiKey, isNull);
    expect(storage.saved, isNull);
    expect(storage.clearCount, 1);
  });
}
