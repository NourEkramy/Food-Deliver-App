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
import 'package:food_delivery/features/profile/cubit/profile_state.dart';
import 'package:food_delivery/features/profile/repository/profile_repository.dart';
import 'package:food_delivery/features/profile/view/change_password_screen.dart';
import 'package:food_delivery/features/profile/view/edit_profile_screen.dart';
import 'package:food_delivery/features/profile/view/profile_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

import 'auth_cubit_test.dart';

/// Records the whole request so the endpoint's exact shape can be asserted.
class RecordingAdapter implements HttpClientAdapter {
  final int status;
  final Object body;
  RequestOptions? last;

  /// The bytes actually sent, decoded.
  ///
  /// [RequestOptions.data] is the value handed to Dio *before* its transformer
  /// runs, so asserting on it cannot tell whether a String was JSON-encoded.
  /// A test on that field passed while the wire carried `hunter2` instead of
  /// `"hunter2"`, which the server rejected.
  String? sentBody;

  RecordingAdapter({this.status = 200, this.body = const {}});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      sentBody = utf8.decode(chunks.expand((chunk) => chunk).toList());
    }
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
    // The endpoint takes one [FromBody] string: the new password. An object
    // body returns "The JSON value could not be converted to System.String",
    // and the companion "NewPassword is required" is the same parameter
    // reported again — not a second, separate one.
    test('sends the password as a bare string body', () async {
      final adapter = RecordingAdapter();

      await repoWith(
        adapter,
      ).changePassword(apiKey: 'KEY-1', newPassword: 'secret123');

      expect(adapter.last!.method, 'PUT');
      expect(adapter.last!.path, '/User/KEY-1');
      // Quoted: a JSON string, which is what the server binds to
      // `[FromBody] string`. Unquoted, it reads the leading digits of a
      // numeric password as a number and fails on the first letter.
      expect(adapter.sentBody, '"secret123"');
    });

    test('quotes a password that would otherwise parse as a number', () async {
      final adapter = RecordingAdapter();

      await repoWith(
        adapter,
      ).changePassword(apiKey: 'KEY-1', newPassword: '1234567Nour');

      expect(adapter.sentBody, '"1234567Nour"');
    });

    test('escapes a quote that would otherwise break the JSON', () async {
      final adapter = RecordingAdapter();

      await repoWith(
        adapter,
      ).changePassword(apiKey: 'KEY-1', newPassword: 'pa"ss');

      // Escaped rather than pasted in raw, so the body stays valid JSON.
      expect(adapter.sentBody, r'"pa\"ss"');
    });

    test('sends no query parameters', () async {
      final adapter = RecordingAdapter();

      await repoWith(
        adapter,
      ).changePassword(apiKey: 'KEY-1', newPassword: 'secret123');

      expect(adapter.last!.queryParameters, isEmpty);
    });

    test('deletes by api key in the path', () async {
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
        () => repoWith(
          adapter,
        ).changePassword(apiKey: 'bad', newPassword: 'secret123'),
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

  group('saving the name', () {
    test('never touches the network', () async {
      final adapter = RecordingAdapter();
      final auth = signedInCubit(name: 'Old');

      await ProfileCubit(repoWith(adapter), auth).saveName('New Name');

      // There is no name field on the server, so nothing should have been sent.
      expect(adapter.last, isNull);
      expect(auth.state.name, 'New Name');
      expect(auth.state.displayName, 'New Name');
    });

    test('leaves the email alone', () async {
      final auth = signedInCubit(email: 'nour@example.com');

      await ProfileCubit(repoWith(RecordingAdapter()), auth).saveName('New');

      expect(auth.state.email, 'nour@example.com');
    });

    test('re-persists only when the session was remembered', () async {
      final remembered = FakeSessionStorage(
        const Session(apiKey: 'KEY-1', email: 'nour@example.com', name: 'Old'),
      );
      final auth = signedInCubit(storage: remembered);

      await ProfileCubit(repoWith(RecordingAdapter()), auth).saveName('New');

      expect(remembered.saved?.name, 'New');
      expect(remembered.saved?.email, 'nour@example.com');
      expect(remembered.saved?.apiKey, 'KEY-1');
    });

    test('does not start remembering a session that was not stored', () async {
      // "Remember me" was off, so saving a name must not quietly turn it on.
      final storage = FakeSessionStorage();
      final auth = signedInCubit(storage: storage);

      await ProfileCubit(repoWith(RecordingAdapter()), auth).saveName('New');

      expect(storage.saved, isNull);
      expect(auth.state.name, 'New', reason: 'memory still updates');
    });
  });

  group('changing the password', () {
    test('reports success', () async {
      final auth = signedInCubit();
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);

      await profile.changePassword('secret123');

      expect(profile.state.outcome, ProfileOutcome.passwordChanged);
      expect(profile.state.errorMessage, isNull);
    });

    test('reports the server error and stays put', () async {
      final auth = signedInCubit();
      final profile = ProfileCubit(
        repoWith(
          RecordingAdapter(
            status: 404,
            body: {'message': 'No User Data Found'},
          ),
        ),
        auth,
      );

      await profile.changePassword('secret123');

      expect(profile.state.errorMessage, 'No User Data Found');
      expect(profile.state.outcome, ProfileOutcome.none);
      expect(profile.state.isBusy, isFalse);
    });
  });

  group('deleting the account', () {
    test('signs the user out afterwards', () async {
      final auth = signedInCubit();
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);

      await profile.deleteAccount();

      expect(profile.state.outcome, ProfileOutcome.accountDeleted);
      // The key now refers to a user that no longer exists.
      expect(auth.state.status, AuthStatus.signedOut);
      expect(auth.state.apiKey, isNull);
    });

    test('keeps the user signed in when the delete fails', () async {
      final auth = signedInCubit();
      final profile = ProfileCubit(
        repoWith(RecordingAdapter(status: 500, body: {'message': 'Nope'})),
        auth,
      );

      await profile.deleteAccount();

      expect(profile.state.errorMessage, 'Nope');
      expect(auth.state.isAuthenticated, isTrue);
    });
  });

  group('screens', () {
    testWidgets('profile shows the name, email and account actions', (
      tester,
    ) async {
      final auth = signedInCubit();
      await pumpProfile(
        tester,
        const ProfileScreen(),
        auth: auth,
        profile: ProfileCubit(repoWith(RecordingAdapter()), auth),
      );

      expect(find.text('Nour Ekramy'), findsWidgets);
      expect(find.text('nour@example.com'), findsWidgets);
      expect(find.text('Saved on this device only'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('the avatar shows initials', (tester) async {
      final auth = signedInCubit(name: 'Nour Ekramy');
      await pumpProfile(
        tester,
        const ProfileScreen(),
        auth: auth,
        profile: ProfileCubit(repoWith(RecordingAdapter()), auth),
      );

      expect(find.text('NE'), findsOneWidget);
    });

    testWidgets('a single-word name gives one initial', (tester) async {
      final auth = signedInCubit(name: 'Nour');
      await pumpProfile(
        tester,
        const ProfileScreen(),
        auth: auth,
        profile: ProfileCubit(repoWith(RecordingAdapter()), auth),
      );

      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('edit offers a name field and a locked email', (tester) async {
      final auth = signedInCubit();
      await pumpProfile(
        tester,
        const EditProfileScreen(),
        auth: auth,
        profile: ProfileCubit(repoWith(RecordingAdapter()), auth),
      );

      // One editable field only — the password is on its own screen now.
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('nour@example.com'), findsOneWidget);
      expect(
        find.text('Your email cannot be changed on this account'),
        findsOneWidget,
      );
    });

    testWidgets('edit saves the name without asking for a password', (
      tester,
    ) async {
      final auth = signedInCubit(name: 'Old');
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);
      await pumpProfile(
        tester,
        const EditProfileScreen(),
        auth: auth,
        profile: profile,
      );

      await tester.enterText(find.byType(TextFormField), 'New Name');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(auth.state.name, 'New Name');
      expect(profile.state.outcome, ProfileOutcome.nameSaved);
    });

    testWidgets('edit refuses an empty name', (tester) async {
      final auth = signedInCubit();
      final profile = ProfileCubit(repoWith(RecordingAdapter()), auth);
      await pumpProfile(
        tester,
        const EditProfileScreen(),
        auth: auth,
        profile: profile,
      );

      await tester.enterText(find.byType(TextFormField), '');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('change password refuses a mismatch', (tester) async {
      final auth = signedInCubit();
      final adapter = RecordingAdapter();
      final profile = ProfileCubit(repoWith(adapter), auth);
      await pumpProfile(
        tester,
        const ChangePasswordScreen(),
        auth: auth,
        profile: profile,
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'secret123');
      await tester.enterText(fields.at(1), 'different');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(adapter.last, isNull, reason: 'nothing should have been sent');
    });

    testWidgets('change password sends a matching pair', (tester) async {
      final auth = signedInCubit();
      final adapter = RecordingAdapter();
      final profile = ProfileCubit(repoWith(adapter), auth);
      await pumpProfile(
        tester,
        const ChangePasswordScreen(),
        auth: auth,
        profile: profile,
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'secret123');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(adapter.sentBody, '"secret123"');
    });
  });
}
