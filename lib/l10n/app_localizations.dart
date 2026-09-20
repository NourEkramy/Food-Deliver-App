import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name, shown on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Food Delivery'**
  String get appName;

  /// Label above the delivery address in the home header.
  ///
  /// In en, this message translates to:
  /// **'DELIVER TO'**
  String get deliveryTo;

  /// Welcome line on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}, Good Afternoon!'**
  String greeting(String name);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search dishes, restaurants'**
  String get searchHint;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @openRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Open Restaurants'**
  String get openRestaurants;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to your existing account'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get password;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@gmail.com'**
  String get emailHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUp;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign up to get started'**
  String get signUpSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'John doe'**
  String get nameHint;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'RE-TYPE PASSWORD'**
  String get retypePassword;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created. Welcome!'**
  String get accountCreated;

  /// Number of menu items a restaurant has.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No dishes} =1{1 dish} other{{count} dishes}}'**
  String dishCount(int count);

  /// No description provided for @parkingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parkingAvailable;

  /// No description provided for @noParking.
  ///
  /// In en, this message translates to:
  /// **'No parking'**
  String get noParking;

  /// No description provided for @setDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Set delivery address'**
  String get setDeliveryAddress;

  /// No description provided for @menuLabel.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuLabel;

  /// No description provided for @cartLabel.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartLabel;

  /// No description provided for @noRestaurants.
  ///
  /// In en, this message translates to:
  /// **'No restaurants here yet'**
  String get noRestaurants;

  /// No description provided for @restaurantView.
  ///
  /// In en, this message translates to:
  /// **'Restaurant View'**
  String get restaurantView;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @menuSection.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuSection;

  /// No description provided for @sortByPrice.
  ///
  /// In en, this message translates to:
  /// **'Sort by price'**
  String get sortByPrice;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Highest price'**
  String get priceHighToLow;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCart;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add dishes from a restaurant to get started'**
  String get cartEmptyHint;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY ADDRESS'**
  String get deliveryAddress;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalLabel;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'PLACE ORDER'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlaced;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear cart'**
  String get clearCart;

  /// No description provided for @newCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new cart?'**
  String get newCartTitle;

  /// No description provided for @newCartBody.
  ///
  /// In en, this message translates to:
  /// **'Your cart has items from {restaurant}. Ordering from somewhere else will empty it.'**
  String newCartBody(String restaurant);

  /// No description provided for @startNewCart.
  ///
  /// In en, this message translates to:
  /// **'Start new cart'**
  String get startNewCart;

  /// No description provided for @keepCart.
  ///
  /// In en, this message translates to:
  /// **'Keep my cart'**
  String get keepCart;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not ordered anything yet'**
  String get ordersEmpty;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelOrder;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'#{id}'**
  String orderNumber(String id);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get searchDishes;

  /// No description provided for @searchRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get searchRestaurants;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched that'**
  String get noResults;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for a dish or a restaurant'**
  String get searchPrompt;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get confirmNewPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @nameStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only'**
  String get nameStoredLocally;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account'**
  String get changePasswordSubtitle;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @emailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Your email cannot be changed on this account'**
  String get emailCannotChange;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and you will be signed out. It cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @saveName.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveName;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'ITEMS'**
  String get orderItems;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'That order could not be found'**
  String get orderNotFound;

  /// No description provided for @onbTitle1.
  ///
  /// In en, this message translates to:
  /// **'All your favorites'**
  String get onbTitle1;

  /// No description provided for @onbBody1.
  ///
  /// In en, this message translates to:
  /// **'Order from the best local restaurants with easy, on-demand delivery.'**
  String get onbBody1;

  /// No description provided for @onbTitle2.
  ///
  /// In en, this message translates to:
  /// **'Free delivery offers'**
  String get onbTitle2;

  /// No description provided for @onbBody2.
  ///
  /// In en, this message translates to:
  /// **'Free delivery for new customers via Apple Pay and others payment methods.'**
  String get onbBody2;

  /// No description provided for @onbTitle3.
  ///
  /// In en, this message translates to:
  /// **'Choose your food'**
  String get onbTitle3;

  /// No description provided for @onbBody3.
  ///
  /// In en, this message translates to:
  /// **'Easily find your type of food craving and you\'ll get delivery in wide range.'**
  String get onbBody3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS'**
  String get addressLine;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'STREET'**
  String get street;

  /// No description provided for @postCode.
  ///
  /// In en, this message translates to:
  /// **'POST CODE'**
  String get postCode;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'APARTMENT'**
  String get apartment;

  /// No description provided for @labelAs.
  ///
  /// In en, this message translates to:
  /// **'LABEL AS'**
  String get labelAs;

  /// No description provided for @labelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelHome;

  /// No description provided for @labelWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelWork;

  /// No description provided for @labelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelOther;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'SAVE LOCATION'**
  String get saveLocation;

  /// No description provided for @noAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet'**
  String get noAddresses;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get addressRequired;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addressSaved;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address removed'**
  String get addressDeleted;

  /// No description provided for @chooseAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose an address'**
  String get chooseAddress;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW'**
  String get addNewCard;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'CARD HOLDER NAME'**
  String get cardHolder;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'CARD NUMBER'**
  String get cardNumber;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'EXPIRY DATE'**
  String get expiry;

  /// No description provided for @cvc.
  ///
  /// In en, this message translates to:
  /// **'CVC'**
  String get cvc;

  /// No description provided for @addAndPay.
  ///
  /// In en, this message translates to:
  /// **'ADD & MAKE PAYMENT'**
  String get addAndPay;

  /// No description provided for @payAndConfirm.
  ///
  /// In en, this message translates to:
  /// **'PAY & CONFIRM'**
  String get payAndConfirm;

  /// No description provided for @cardRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a card number'**
  String get cardRequired;

  /// No description provided for @cardInvalid.
  ///
  /// In en, this message translates to:
  /// **'Card number must be 16 digits'**
  String get cardInvalid;

  /// No description provided for @expiryRequired.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryRequired;

  /// No description provided for @cvcRequired.
  ///
  /// In en, this message translates to:
  /// **'3 digits'**
  String get cvcRequired;

  /// No description provided for @holderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the cardholder name'**
  String get holderRequired;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No saved cards'**
  String get noCards;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'You successfully made a payment, enjoy our service!'**
  String get paymentSuccessBody;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'TRACK ORDER'**
  String get trackOrder;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get backToHome;

  /// No description provided for @cardsAreLocal.
  ///
  /// In en, this message translates to:
  /// **'Cards are stored on this device only. Never enter a real card number.'**
  String get cardsAreLocal;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to your existing account'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'SEND CODE'**
  String get sendCode;

  /// No description provided for @forgotPasswordUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This demo backend has no password reset endpoint, so no email will be sent.'**
  String get forgotPasswordUnavailable;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
