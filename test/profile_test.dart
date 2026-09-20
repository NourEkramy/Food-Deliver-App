import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/storage/session_storage.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/features/auth/cubit/auth_cubit.dart';
import 'package:food_delivery/features/auth/cubit/auth_state.dart';
import 'package:food_delivery/features/profile/cubit/profile_cubit.dart';
import 'package:food_delivery/features/profile/repository/profile_repository.dart';
import 'package:food_delivery/features/profile/view/edit_profile_screen.dart';
import 'package:food_delivery/features/profile/view/profile_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'auth_cubit_test.dart';

/// Records the whole request so the endpoint's unusual shape can be asserted.
class RecordingAdapter implements HttpClientAdapter {
  final int status;
  final Object body;
  RequestOptions? last;

  RecordingAdapter({this.status = 200, this.body = const {}});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ProfileRepository repoWith(RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
    ..httpClientAdapter = adapter;
  return ProfileRepository(dio);
}

/// Pumps a profile screen at a viewport tall enough for the whole form.
///
/// The default 800x600 test window puts the SAVE button below the fold, where
/// a tap lands on nothing and the test fails for the wrong reason.
Future<void> pumpProfile(
  WidgetTester tester,
  Widget child, {
  required AuthCubit auth,
  ProfileCubit? profile,
}) async {
  tester.view.physicalSize = const Size(375 * 3, 1000 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(wrap(child, auth: auth, profile: profile));
  await tester.pumpAndSettle();
}

Widget wrap(Widget child, {required AuthCubit auth, ProfileCubit? profile}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: auth),
      if (profile != null) BlocProvider.value(value: profile),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

AuthCubit signedInCubit({
  String name = 'Nour Ekramy',
  String email = 'nour@example.com',
  FakeSessionStorage? storage,
}) {
  final cubit = AuthCubit(
    FakeAuthRepository(apiKey: 'KEY-1'),
    storage ?? FakeSessionStorage(),
  );
  cubit.emit(
    AuthState(
      status: AuthStatus.signedIn,
      apiKey: 'KEY-1',
      email: email,
      name: name,
    ),
  );
  return cubit;
}

void main() {
  group('the PUT contract', () {
    // Worked out by probing the live endpoint: NewPassword is a query
    // parameter and the new email is the body as a bare JSON string. Sending
    // an object instead returns "The JSON value could not be converted to
    // System.String".
    test('sends the password as a query parameter', () async {
      final adapter = RecordingAdapter();

      await repoWith(adapter).updateProfile(
        apiKey: 'KEY-1',
        email: 'new@example.com',
        newPassword: 'secret123',
      );

      expect(adapter.last!.method, 'PUT');
      expect(adapter.last!.path, '/User/KEY-1');
      expect(adapter.last!.queryParameters, {'NewPassword': 'secret123'});
    });

    test('sends the email as the body, not wrapped in an object', () async {
      final adapter = RecordingAdapter();

      await repoWith(adapter).updateProfile(
        apiKey: 'KEY-1',
        email: 'new@example.com',
        newPassword: 'secret123',
      );

      expect(adapter.last!.data, 'new@example.com');
      expect(adapter.last!.data, isNot(isA<Map>()));
    });

    test('puts the api key in the path', () async {
      final adapter = RecordingAdapter();
      await repoWith(adapter).deleteAccount('KEY-9');

      expect(adapter.last!.method, 'DELETE');
      expect(adapter.last!.path, '/User/KEY-9');
    });

    test('surfaces the server message on failure', () async {
      final adapter = RecordingAdapter(
        status: 404,
        body: {'message': 'No User Data Found'},
      );

      expect(
        () => repoWith(adapter).updateProfile(
          apiKey: 'bad',
          email: 'a@b.com',
          newPassword: 'secret123',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No User Data Found'),
          ),
        ),
      );
    });
  });

  group('saving', () {
    test('updates the live session so the greeting changes', () async {
      final auth = signedInCubit(name: 'Old', email: 'old@example.com');
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);

      await profile.save(
        name: 'New Name',
        email: 'new@example.com',
        newPassword: 'secret123',
      );

      expect(auth.state.name, 'New Name');
      expect(auth.state.email, 'new@example.com');
      expect(auth.state.displayName, 'New Name');
      expect(profile.state.justSaved, isTrue);
    });

    test('re-persists only when the session was remembered', () async {
      final remembered = FakeSessionStorage(
        const Session(apiKey: 'KEY-1', email: 'old@example.com', name: 'Old'),
      );
      final auth = signedInCubit(storage: remembered);
      await ProfileCubit(repoWith(RecordingAdapter()), auth).save(
        name: 'New Name',
        email: 'new@example.com',
        newPassword: 'secret123',
      );

      expect(remembered.saved?.name, 'New Name');
      expect(remembered.saved?.email, 'new@example.com');
      // The key is carried through, not dropped.
      expect(remembered.saved?.apiKey, 'KEY-1');
    });

    test('does not start remembering a session that was not stored', () async {
      // "Remember me" was off, so saving a profile must not quietly turn it on.
      final storage = FakeSessionStorage();
      final auth = signedInCubit(storage: storage);

      await ProfileCubit(repoWith(RecordingAdapter()), auth).save(
        name: 'New Name',
        email: 'new@example.com',
        newPassword: 'secret123',
      );

      expect(storage.saved, isNull);
      expect(auth.state.name, 'New Name', reason: 'memory still updates');
    });

    test('keeps the session unchanged when the server rejects it', () async {
      final auth = signedInCubit(name: 'Old', email: 'old@example.com');
      final profile = ProfileCubit(
        repoWith(
          RecordingAdapter(
            status: 404,
            body: {'message': 'No User Data Found'},
          ),
        ),
        auth,
      );

      await profile.save(
        name: 'New Name',
        email: 'new@example.com',
        newPassword: 'secret123',
      );

      expect(profile.state.errorMessage, 'No User Data Found');
      expect(auth.state.name, 'Old');
      expect(auth.state.email, 'old@example.com');
    });
  });

  group('screens', () {
    testWidgets('profile shows the name and email from the session', (
      tester,
    ) async {
      await pumpProfile(tester, const ProfileScreen(), auth: signedInCubit());

      expect(find.text('Nour Ekramy'), findsWidgets);
      expect(find.text('nour@example.com'), findsWidgets);
      // The name never reaches the server, and the screen says so.
      expect(find.text('Saved on this device only'), findsOneWidget);
    });

    testWidgets('the avatar shows initials', (tester) async {
      await pumpProfile(
        tester,
        const ProfileScreen(),
        auth: signedInCubit(name: 'Nour Ekramy'),
      );

      expect(find.text('NE'), findsOneWidget);
    });

    testWidgets('a single-word name gives one initial', (tester) async {
      await pumpProfile(
        tester,
        const ProfileScreen(),
        auth: signedInCubit(name: 'Nour'),
      );

      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('edit pre-fills from the session', (tester) async {
      final auth = signedInCubit();
      await pumpProfile(
        tester,
        const EditProfileScreen(),
        auth: auth,
        profile: ProfileCubit(repoWith(RecordingAdapter()), auth),
      );

      expect(find.text('Nour Ekramy'), findsWidgets);
      expect(find.text('nour@example.com'), findsWidgets);
    });

    testWidgets('edit refuses to save without a password', (tester) async {
      final auth = signedInCubit();
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);
      await pumpProfile(
        tester,
        const EditProfileScreen(),
        auth: auth,
        profile: profile,
      );

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
      expect(profile.state.justSaved, isFalse);
    });

    testWidgets('edit refuses mismatched passwords', (tester) async {
      final auth = signedInCubit();
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);
      await pumpProfile(
        tester,
        const EditProfileScreen(),
        auth: auth,
        profile: profile,
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(2), 'secret123');
      await tester.enterText(fields.at(3), 'different');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(profile.state.justSaved, isFalse);
    });
  });
}
