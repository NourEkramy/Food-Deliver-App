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

  @override
  String dishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
      zero: 'No dishes',
    );
    return '$_temp0';
  }

  @override
  String get parkingAvailable => 'Parking';

  @override
  String get noParking => 'No parking';

  @override
  String get setDeliveryAddress => 'Set delivery address';

  @override
  String get menuLabel => 'Menu';

  @override
  String get cartLabel => 'Cart';

  @override
  String get noRestaurants => 'No restaurants here yet';

  @override
  String get restaurantView => 'Restaurant View';

  @override
  String get details => 'Details';

  @override
  String get menuSection => 'Menu';

  @override
  String get sortByPrice => 'Sort by price';

  @override
  String get priceLowToHigh => 'Lowest price';

  @override
  String get priceHighToLow => 'Highest price';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String get quantity => 'Quantity';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyHint => 'Add dishes from a restaurant to get started';

  @override
  String get deliveryAddress => 'DELIVERY ADDRESS';

  @override
  String get totalLabel => 'TOTAL';

  @override
  String get placeOrder => 'PLACE ORDER';

  @override
  String get orderPlaced => 'Order placed';

  @override
  String get removeItem => 'Remove';

  @override
  String get clearCart => 'Clear cart';

  @override
  String get newCartTitle => 'Start a new cart?';

  @override
  String newCartBody(String restaurant) {
    return 'Your cart has items from $restaurant. Ordering from somewhere else will empty it.';
  }

  @override
  String get startNewCart => 'Start new cart';

  @override
  String get keepCart => 'Keep my cart';

  @override
  String get myOrders => 'My Orders';

  @override
  String get ordersEmpty => 'You have not ordered anything yet';

  @override
  String get cancelOrder => 'Cancel';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String orderNumber(String id) {
    return '#$id';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get search => 'Search';

  @override
  String get searchDishes => 'Dishes';

  @override
  String get searchRestaurants => 'Restaurants';

  @override
  String get noResults => 'Nothing matched that';

  @override
  String get searchPrompt => 'Search for a dish or a restaurant';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get viewCart => 'View cart';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get edit => 'EDIT';

  @override
  String get fullName => 'FULL NAME';

  @override
  String get newPassword => 'NEW PASSWORD';

  @override
  String get confirmNewPassword => 'CONFIRM PASSWORD';

  @override
  String get save => 'SAVE';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get nameStoredLocally => 'Saved on this device only';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Choose a new password for your account';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get emailCannotChange =>
      'Your email cannot be changed on this account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account and you will be signed out. It cannot be undone.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get saveName => 'SAVE';

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get orderItems => 'ITEMS';

  @override
  String get orderNotFound => 'That order could not be found';
}
