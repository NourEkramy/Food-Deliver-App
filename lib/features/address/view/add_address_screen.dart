import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/address_cubit.dart';
import '../model/address.dart';

/// The address form.
///
/// The design puts a draggable map pin at the top. There is no map SDK in this
/// project and no geocoding endpoint, so that area is a labelled placeholder
/// rather than a picture of a map that cannot be moved.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lineController = TextEditingController();
  final _streetController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _apartmentController = TextEditingController();
  AddressLabel _label = AddressLabel.home;

  @override
  void dispose() {
    _lineController.dispose();
    _streetController.dispose();
    _postCodeController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await context.read<AddressCubit>().add(
      Address(
        // Local ids only, so the clock is a sufficient source of uniqueness.
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        line: _lineController.text.trim(),
        street: _streetController.text.trim(),
        postCode: _postCodeController.text.trim(),
        apartment: _apartmentController.text.trim(),
        label: _label,
      ),
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.addressSaved)));
    navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.addNewAddress),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: l10n.addressLine,
                        hint: '3235 Royal Ln. Mesa',
                        controller: _lineController,
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? l10n.addressRequired
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: l10n.street,
                              hint: 'Hason Nagar',
                              controller: _streetController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              label: l10n.postCode,
                              hint: '34567',
                              controller: _postCodeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: l10n.apartment,
                        hint: '345',
                        controller: _apartmentController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n.labelAs,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          for (final label in AddressLabel.values)
                            _LabelChip(
                              label: _labelText(label, l10n),
                              selected: _label == label,
                              onTap: () => setState(() => _label = label),
                            ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(l10n.saveLocation),
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

  String _labelText(AddressLabel label, AppLocalizations l10n) =>
      switch (label) {
        AddressLabel.home => l10n.labelHome,
        AddressLabel.work => l10n.labelWork,
        AddressLabel.other => l10n.labelOther,
      };
}

class _LabelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LabelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.inputFill,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
