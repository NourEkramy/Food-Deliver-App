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
}
