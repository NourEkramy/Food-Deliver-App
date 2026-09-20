import 'package:equatable/equatable.dart';

/// What the user labelled an address as. The design offers exactly these three.
enum AddressLabel { home, work, other }

/// A delivery address.
///
/// Entirely local: the API has no address endpoint, so these are saved on the
/// device and never leave it. `makeorder` takes no address either, which is why
/// choosing one changes what the cart displays but not what is sent.
class Address extends Equatable {
  final String id;
  final String line;
  final String street;
  final String postCode;
  final String apartment;
  final AddressLabel label;

  const Address({
    required this.id,
    required this.line,
    this.street = '',
    this.postCode = '',
    this.apartment = '',
    this.label = AddressLabel.home,
  });

  /// One line for the cart and the address list.
  String get summary {
    final parts = [
      if (apartment.isNotEmpty) apartment,
      if (street.isNotEmpty) street,
      line,
      if (postCode.isNotEmpty) postCode,
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'line': line,
    'street': street,
    'postCode': postCode,
    'apartment': apartment,
    'label': label.name,
  };

  static Address? tryParse(Map<String, dynamic> json) {
    final id = json['id'];
    final line = json['line'];
    if (id is! String || line is! String || line.isEmpty) return null;

    return Address(
      id: id,
      line: line,
      street: json['street'] as String? ?? '',
      postCode: json['postCode'] as String? ?? '',
      apartment: json['apartment'] as String? ?? '',
      label: AddressLabel.values.firstWhere(
        (value) => value.name == json['label'],
        orElse: () => AddressLabel.other,
      ),
    );
  }

  @override
  List<Object?> get props => [id, line, street, postCode, apartment, label];
}
