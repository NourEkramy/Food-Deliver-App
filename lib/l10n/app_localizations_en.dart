// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Food Delivery';

  @override
  String get deliveryTo => 'DELIVER TO';

  @override
  String greeting(String name) {
    return 'Hey $name, Good Afternoon!';
  }

  @override
  String get searchHint => 'Search dishes, restaurants';

  @override
  String get allCategories => 'All Categories';

  @override
  String get seeAll => 'See All';

  @override
  String get openRestaurants => 'Open Restaurants';

  @override
  String get all => 'All';

  @override
  String get logIn => 'Log In';

  @override
  String get loginSubtitle => 'Please sign in to your existing account';

  @override
  String get email => 'EMAIL';

  @override
  String get password => 'PASSWORD';

  @override
  String get emailHint => 'example@gmail.com';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'SIGN UP';

  @override
  String get or => 'Or';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get logout => 'Log Out';

  @override
  String get signUpTitle => 'Sign Up';

  @override
  String get signUpSubtitle => 'Please sign up to get started';

  @override
  String get name => 'NAME';

  @override
  String get nameHint => 'John doe';

  @override
  String get retypePassword => 'RE-TYPE PASSWORD';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreated => 'Account created. Welcome!';
}
