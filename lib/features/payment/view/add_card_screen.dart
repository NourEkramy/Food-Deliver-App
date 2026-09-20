import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/payment_cubit.dart';

/// Adds a card.
///
/// The number is used to derive the brand and the last four digits, then
/// discarded — see [PaymentCubit.addCard]. The expiry and CVC are checked for
/// shape and never stored at all, because nothing in this app could
/// legitimately use them.
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    await context.read<PaymentCubit>().addCard(
      cardNumber: _numberController.text,
      holder: _holderController.text.trim(),
    );
    navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.addCard),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.cardsAreLocal,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: l10n.cardHolder,
                        hint: 'John Doe',
                        controller: _holderController,
                        keyboardType: TextInputType.name,
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? l10n.holderRequired
                            : null,
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: l10n.cardNumber,
                        hint: '4111 1111 1111 1111',
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        validator: (value) => _validateNumber(value, l10n),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: l10n.expiry,
                              hint: '12/28',
                              controller: _expiryController,
                              keyboardType: TextInputType.datetime,
                              validator: (value) =>
                                  _validateExpiry(value, l10n),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: l10n.cvc,
                              hint: '123',
                              controller: _cvcController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _save(),
                              validator: (value) => _validateCvc(value, l10n),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(l10n.addAndPay),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateNumber(String? value, AppLocalizations l10n) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return l10n.cardRequired;
    if (digits.length != 16) return l10n.cardInvalid;
    return null;
  }

  String? _validateExpiry(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    return RegExp(r'^\d{2}/\d{2}$').hasMatch(text) ? null : l10n.expiryRequired;
  }

  String? _validateCvc(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    return RegExp(r'^\d{3,4}$').hasMatch(text) ? null : l10n.cvcRequired;
  }
}
