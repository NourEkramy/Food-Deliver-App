import 'package:equatable/equatable.dart';

enum PaymentKind { cash, card }

/// A way to pay.
///
/// Local only: the API has no payment endpoint, and `makeorder` takes no
/// payment details — so choosing one changes what the app shows, not what is
/// sent. That is the honest state of this feature.
///
/// Note what is absent: [last4] and nothing more. The full card number is used
/// to derive the brand and the last four digits and is then discarded. A
/// practice app has no business keeping a PAN, and storing one would teach the
/// wrong habit even with made-up numbers.
class PaymentMethod extends Equatable {
  final String id;
  final PaymentKind kind;
  final String brand;
  final String last4;
  final String holder;

  const PaymentMethod({
    required this.id,
    required this.kind,
    this.brand = '',
    this.last4 = '',
    this.holder = '',
  });

  static const cash = PaymentMethod(id: 'cash', kind: PaymentKind.cash);

  /// Brand from the first digit, the usual issuer prefixes.
  static String brandOf(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    if (digits.startsWith('3')) return 'Amex';
    return 'Card';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'brand': brand,
    'last4': last4,
    'holder': holder,
  };

  static PaymentMethod? tryParse(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) return null;

    return PaymentMethod(
      id: id,
      kind: PaymentKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => PaymentKind.card,
      ),
      brand: json['brand'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
      holder: json['holder'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, kind, brand, last4, holder];
}
