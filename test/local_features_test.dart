import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/core/storage/local_store.dart';
import 'package:food_delivery/core/theme/app_theme.dart';
import 'package:food_delivery/features/address/cubit/address_cubit.dart';
import 'package:food_delivery/features/address/model/address.dart';
import 'package:food_delivery/features/address/view/add_address_screen.dart';
import 'package:food_delivery/features/address/view/address_screen.dart';
import 'package:food_delivery/features/auth/view/forgot_password_screen.dart';
import 'package:food_delivery/features/onboarding/view/onboarding_screen.dart';
import 'package:food_delivery/features/onboarding/view/splash_screen.dart';
import 'package:food_delivery/features/payment/cubit/payment_cubit.dart';
import 'package:food_delivery/features/payment/model/payment_method.dart';
import 'package:food_delivery/features/payment/view/add_card_screen.dart';
import 'package:food_delivery/features/payment/view/payment_success_screen.dart';
import 'package:food_delivery/l10n/app_localizations.dart';

/// An in-memory stand-in: the real store reaches for the platform Keystore,
/// which does not exist under `flutter test`.
class FakeLocalStore implements LocalStore {
  final Map<String, Object> data = {};

  @override
  Future<bool> readFlag(String key) async => data[key] == true;

  @override
  Future<void> writeFlag(String key, {required bool value}) async =>
      data[key] = value;

  @override
  Future<String?> readString(String key) async => data[key] as String?;

  @override
  Future<void> writeString(String key, String? value) async {
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readList(String key) async =>
      (data[key] as List<Map<String, dynamic>>?) ?? const [];

  @override
  Future<void> writeList(String key, List<Map<String, dynamic>> items) async =>
      data[key] = items;
}

/// Wraps [child] in an app, with whichever cubits it needs.
///
/// Providers are nested by hand rather than collected into a list: a
/// `List<BlocProvider>` erases the generic, so a cubit would register as a
/// dynamic provider and nothing could find it.
Widget wrap(Widget child, {AddressCubit? address, PaymentCubit? payment}) {
  Widget app = MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );

  if (payment != null) {
    app = BlocProvider.value(value: payment, child: app);
  }
  if (address != null) {
    app = BlocProvider.value(value: address, child: app);
  }
  return app;
}

/// [settle] must be false for screens with an indefinite animation: the splash
/// spinner never stops, so pumpAndSettle would wait for it forever.
Future<void> pumpTall(
  WidgetTester tester,
  Widget child, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(375 * 3, 1100 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(child);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  group('addresses', () {
    test('a saved address becomes the selected one', () async {
      final cubit = AddressCubit(FakeLocalStore());

      await cubit.add(
        const Address(
          id: 'a',
          line: '3235 Royal Ln. Mesa',
          label: AddressLabel.home,
        ),
      );

      expect(cubit.state.addresses, hasLength(1));
      expect(cubit.state.selected?.id, 'a');
    });

    test('falls back to the first when nothing was chosen', () async {
      final cubit = AddressCubit(FakeLocalStore());
      await cubit.add(const Address(id: 'a', line: 'First'));
      await cubit.add(const Address(id: 'b', line: 'Second'));
      cubit.select('b');

      await cubit.remove('b');

      // Removing the selected one must not leave the cart with no address.
      expect(cubit.state.selected?.id, 'a');
    });

    test('survives a round trip through storage', () async {
      final store = FakeLocalStore();
      final first = AddressCubit(store);
      await first.add(
        const Address(
          id: 'a',
          line: '3235 Royal Ln. Mesa',
          street: 'Hason Nagar',
          postCode: '34567',
          apartment: '345',
          label: AddressLabel.work,
        ),
      );

      final second = AddressCubit(store);
      await second.load();

      expect(second.state.addresses, hasLength(1));
      expect(second.state.addresses.single.label, AddressLabel.work);
      expect(second.state.addresses.single.postCode, '34567');
    });

    test('summary reads as one line', () {
      const address = Address(
        id: 'a',
        line: 'Mesa, New Jersey',
        street: 'Hason Nagar',
        postCode: '34567',
        apartment: '345',
      );

      expect(address.summary, '345, Hason Nagar, Mesa, New Jersey, 34567');
    });

    test('a row with no address line is skipped rather than shown blank', () {
      expect(Address.tryParse({'id': 'a'}), isNull);
      expect(Address.tryParse({'id': 'a', 'line': ''}), isNull);
      expect(Address.tryParse({'line': 'somewhere'}), isNull);
    });
  });

  group('payment', () {
    test('stores only the last four digits, never the full number', () async {
      final store = FakeLocalStore();
      final cubit = PaymentCubit(store);

      await cubit.addCard(
        cardNumber: '4111 1111 1111 9876',
        holder: 'Nour Ekramy',
      );

      final card = cubit.state.cards.single;
      expect(card.last4, '9876');
      expect(card.brand, 'Visa');

      // The point of the whole design: the PAN must not be anywhere.
      final written = store.data[LocalStore.keyCards].toString();
      expect(written, isNot(contains('4111')));
      expect(written, isNot(contains('411111111111')));
      expect(written, contains('9876'));
    });

    test('reads the brand from the leading digit', () {
      expect(PaymentMethod.brandOf('4111111111111111'), 'Visa');
      expect(PaymentMethod.brandOf('5500 0000 0000 0004'), 'Mastercard');
      expect(PaymentMethod.brandOf('3400 0000 0000 009'), 'Amex');
      expect(PaymentMethod.brandOf('9999999999999999'), 'Card');
    });

    test('cash is always offered and is the default', () {
      const state = PaymentState();

      expect(state.all.first.kind, PaymentKind.cash);
      expect(state.selected.kind, PaymentKind.cash);
    });

    test('removing the selected card falls back to cash', () async {
      final cubit = PaymentCubit(FakeLocalStore());
      await cubit.addCard(cardNumber: '4111111111111111', holder: 'N');
      final id = cubit.state.cards.single.id;
      expect(cubit.state.selectedId, id);

      await cubit.removeCard(id);

      expect(cubit.state.selected.kind, PaymentKind.cash);
    });
  });

  group('screens render', () {
    testWidgets('splash', (tester) async {
      await pumpTall(tester, wrap(const SplashScreen()), settle: false);
      expect(tester.takeException(), isNull);
      expect(find.text('Food Delivery'), findsOneWidget);
    });

    testWidgets('onboarding advances and finishes', (tester) async {
      var done = false;
      await pumpTall(tester, wrap(OnboardingScreen(onDone: () => done = true)));

      expect(find.text('All your favorites'), findsOneWidget);

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      expect(find.text('Free delivery offers'), findsOneWidget);

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
      // Last page offers GET STARTED rather than NEXT.
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      expect(done, isTrue);
    });

    testWidgets('onboarding can be skipped immediately', (tester) async {
      var done = false;
      await pumpTall(tester, wrap(OnboardingScreen(onDone: () => done = true)));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(done, isTrue);
    });

    testWidgets('address list, empty', (tester) async {
      await pumpTall(
        tester,
        wrap(const AddressScreen(), address: AddressCubit(FakeLocalStore())),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('No saved addresses yet'), findsOneWidget);
    });

    testWidgets('add address refuses an empty address', (tester) async {
      await pumpTall(
        tester,
        wrap(const AddAddressScreen(), address: AddressCubit(FakeLocalStore())),
      );

      await tester.tap(find.text('SAVE LOCATION'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an address'), findsOneWidget);
    });

    testWidgets('add card refuses a short number', (tester) async {
      await pumpTall(
        tester,
        wrap(const AddCardScreen(), payment: PaymentCubit(FakeLocalStore())),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Nour');
      await tester.enterText(fields.at(1), '4111');
      await tester.enterText(fields.at(2), '12/28');
      await tester.enterText(fields.at(3), '123');
      await tester.tap(find.text('ADD & MAKE PAYMENT'));
      await tester.pumpAndSettle();

      expect(find.text('Card number must be 16 digits'), findsOneWidget);
    });

    testWidgets('payment success', (tester) async {
      await pumpTall(tester, wrap(const PaymentSuccessScreen()));
      expect(tester.takeException(), isNull);
      expect(find.text('Congratulations!'), findsOneWidget);
    });

    testWidgets('forgot password says no email will arrive', (tester) async {
      await pumpTall(tester, wrap(const ForgotPasswordScreen()));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('no password reset endpoint'), findsOneWidget);
    });

    testWidgets('the new screens fit in Arabic', (tester) async {
      for (final screen in [
        const SplashScreen(),
        const PaymentSuccessScreen(),
        const ForgotPasswordScreen(),
      ]) {
        tester.view.physicalSize = const Size(375 * 3, 1100 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: screen,
          ),
        );
        // pump, not pumpAndSettle: the splash spinner never stops.
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
