// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'توصيل الطعام';

  @override
  String get deliveryTo => 'التوصيل إلى';

  @override
  String greeting(String name) {
    return 'مرحباً $name، طاب مساؤك!';
  }

  @override
  String get searchHint => 'ابحث عن أطباق أو مطاعم';

  @override
  String get allCategories => 'كل التصنيفات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get openRestaurants => 'المطاعم المفتوحة';

  @override
  String get all => 'الكل';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'الرجاء تسجيل الدخول إلى حسابك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get emailHint => 'example@gmail.com';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get or => 'أو';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get emailRequired => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get passwordRequired => 'الرجاء إدخال كلمة المرور';

  @override
  String get emailInvalid => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get signUpSubtitle => 'الرجاء إنشاء حساب للبدء';

  @override
  String get name => 'الاسم';

  @override
  String get nameHint => 'محمد أحمد';

  @override
  String get retypePassword => 'تأكيد كلمة المرور';

  @override
  String get nameRequired => 'الرجاء إدخال اسمك';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountCreated => 'تم إنشاء الحساب. أهلاً بك!';

  @override
  String dishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طبق',
      many: '$count طبقًا',
      few: '$count أطباق',
      two: 'طبقان',
      one: 'طبق واحد',
      zero: 'لا توجد أطباق',
    );
    return '$_temp0';
  }

  @override
  String get parkingAvailable => 'موقف سيارات';

  @override
  String get noParking => 'لا يوجد موقف';

  @override
  String get setDeliveryAddress => 'حدد عنوان التوصيل';

  @override
  String get menuLabel => 'القائمة';

  @override
  String get cartLabel => 'السلة';

  @override
  String get noRestaurants => 'لا توجد مطاعم هنا بعد';

  @override
  String get restaurantView => 'عرض المطعم';

  @override
  String get details => 'التفاصيل';

  @override
  String get menuSection => 'القائمة';

  @override
  String get sortByPrice => 'ترتيب حسب السعر';

  @override
  String get priceLowToHigh => 'الأقل سعراً';

  @override
  String get priceHighToLow => 'الأعلى سعراً';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get quantity => 'الكمية';

  @override
  String get cart => 'السلة';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get cartEmptyHint => 'أضف أطباقاً من أحد المطاعم للبدء';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get totalLabel => 'الإجمالي';

  @override
  String get placeOrder => 'إتمام الطلب';

  @override
  String get orderPlaced => 'تم إرسال الطلب';

  @override
  String get removeItem => 'إزالة';

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get newCartTitle => 'بدء سلة جديدة؟';

  @override
  String newCartBody(String restaurant) {
    return 'سلتك تحتوي على أطباق من $restaurant. الطلب من مكان آخر سيفرغها.';
  }

  @override
  String get startNewCart => 'ابدأ سلة جديدة';

  @override
  String get keepCart => 'احتفظ بسلتي';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get ordersEmpty => 'لم تطلب أي شيء بعد';

  @override
  String get cancelOrder => 'إلغاء';

  @override
  String get orderCancelled => 'تم إلغاء الطلب';

  @override
  String orderNumber(String id) {
    return '#$id';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصراً',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$_temp0';
  }

  @override
  String get search => 'بحث';

  @override
  String get searchDishes => 'الأطباق';

  @override
  String get searchRestaurants => 'المطاعم';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get searchPrompt => 'ابحث عن طبق أو مطعم';

  @override
  String get addedToCart => 'أُضيف إلى السلة';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get edit => 'تعديل';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور';

  @override
  String get save => 'حفظ';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get nameStoredLocally => 'محفوظ على هذا الجهاز فقط';

  @override
  String get accountSection => 'الحساب';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changePasswordSubtitle => 'اختر كلمة مرور جديدة لحسابك';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get emailCannotChange => 'لا يمكن تغيير بريدك الإلكتروني لهذا الحساب';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف حسابك؟';

  @override
  String get deleteAccountBody =>
      'سيؤدي هذا إلى حذف حسابك نهائياً وتسجيل خروجك. لا يمكن التراجع عن ذلك.';

  @override
  String get accountDeleted => 'تم حذف الحساب';

  @override
  String get saveName => 'حفظ';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get orderItems => 'العناصر';

  @override
  String get orderNotFound => 'تعذّر العثور على هذا الطلب';

  @override
  String get onbTitle1 => 'كل ما تحب';

  @override
  String get onbBody1 => 'اطلب من أفضل المطاعم القريبة مع توصيل سريع وسهل.';

  @override
  String get onbTitle2 => 'عروض توصيل مجاني';

  @override
  String get onbBody2 => 'توصيل مجاني للعملاء الجدد عبر وسائل دفع متعددة.';

  @override
  String get onbTitle3 => 'اختر طعامك';

  @override
  String get onbBody3 => 'اعثر بسهولة على ما تشتهيه واحصل عليه أينما كنت.';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get myAddresses => 'عناويني';

  @override
  String get addNewAddress => 'إضافة عنوان';

  @override
  String get addressLine => 'العنوان';

  @override
  String get street => 'الشارع';

  @override
  String get postCode => 'الرمز البريدي';

  @override
  String get apartment => 'الشقة';

  @override
  String get labelAs => 'تصنيف';

  @override
  String get labelHome => 'المنزل';

  @override
  String get labelWork => 'العمل';

  @override
  String get labelOther => 'أخرى';

  @override
  String get saveLocation => 'حفظ العنوان';

  @override
  String get noAddresses => 'لا توجد عناوين محفوظة';

  @override
  String get addressRequired => 'الرجاء إدخال العنوان';

  @override
  String get addressSaved => 'تم حفظ العنوان';

  @override
  String get addressDeleted => 'تم حذف العنوان';

  @override
  String get chooseAddress => 'اختر عنواناً';

  @override
  String get payment => 'الدفع';

  @override
  String get paymentCash => 'نقداً';

  @override
  String get paymentCard => 'بطاقة';

  @override
  String get addNewCard => 'إضافة';

  @override
  String get addCard => 'إضافة بطاقة';

  @override
  String get cardHolder => 'اسم حامل البطاقة';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get expiry => 'تاريخ الانتهاء';

  @override
  String get cvc => 'الرمز السري';

  @override
  String get addAndPay => 'إضافة وإتمام الدفع';

  @override
  String get payAndConfirm => 'ادفع وأكّد';

  @override
  String get cardRequired => 'الرجاء إدخال رقم البطاقة';

  @override
  String get cardInvalid => 'رقم البطاقة يجب أن يكون ١٦ رقماً';

  @override
  String get expiryRequired => 'شهر/سنة';

  @override
  String get cvcRequired => '٣ أرقام';

  @override
  String get holderRequired => 'الرجاء إدخال اسم حامل البطاقة';

  @override
  String get noCards => 'لا توجد بطاقات محفوظة';

  @override
  String get paymentSuccessTitle => 'تهانينا!';

  @override
  String get paymentSuccessBody => 'تم الدفع بنجاح، نتمنى لك تجربة ممتعة!';

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get cardsAreLocal =>
      'تُحفظ البطاقات على هذا الجهاز فقط. لا تُدخل رقم بطاقة حقيقية.';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle => 'الرجاء تسجيل الدخول إلى حسابك';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get forgotPasswordUnavailable =>
      'لا يوفر هذا الخادم التجريبي خدمة استعادة كلمة المرور، لذا لن يُرسل أي بريد.';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';
}
