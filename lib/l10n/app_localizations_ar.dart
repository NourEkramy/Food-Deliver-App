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
  String get passwordNeededToSave =>
      'يطلب الخادم كلمة مرور مع كل تعديل، لذا أدخل كلمة مرور للحفظ.';

  @override
  String get nameStoredLocally => 'محفوظ على هذا الجهاز فقط';

  @override
  String get accountSection => 'الحساب';
}
