import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats a price for display.
///
/// The API returns bare numbers with no currency field. The data is plainly
/// Indian — restaurants in Hyderabad, Jaipur and Mumbai, dishes from 40 to 550
/// — so rupees is the honest reading of it. The design shows dollars, but
/// relabelling ₹500 as $500 would misstate the price by a factor of eighty.
///
/// Keeping this in one function means a currency change is a one-line edit
/// rather than a hunt through every screen.
String formatPrice(BuildContext context, num amount) {
  final locale = Localizations.localeOf(context).toString();

  return NumberFormat.currency(
    locale: locale,
    symbol: '₹',
    // Every price in the dataset is a whole number; showing .00 everywhere
    // adds noise without adding information.
    decimalDigits: 0,
  ).format(amount);
}
