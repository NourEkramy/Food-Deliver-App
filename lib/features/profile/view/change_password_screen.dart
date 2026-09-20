import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

/// Sets a new password.
///
/// Its own screen rather than a field on the edit form: changing a password is
/// a deliberate act, and `PUT /User/{apikey}` does nothing else, so bundling it
/// into "save your name" would mean every name change also reset the password.
///
/// The API does not ask for the current password — only the new one.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileCubit>().changePassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          current.outcome == ProfileOutcome.passwordChanged,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: l10n.changePassword),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.changePasswordSubtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppTextField(
                          label: l10n.newPassword,
                          hint: '••••••••••',
                          controller: _passwordController,
                          obscure: true,
                          validator: (value) => _validate(value, l10n),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: l10n.confirmNewPassword,
                          hint: '••••••••••',
                          controller: _confirmController,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (value) =>
                              value != _passwordController.text
                              ? l10n.passwordsDoNotMatch
                              : null,
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.errorMessage != null) ...[
                                  ErrorBanner(message: state.errorMessage!),
                                  const SizedBox(height: 16),
                                ],
                                ElevatedButton(
                                  onPressed: state.isBusy ? null : _submit,
                                  child: state.isBusy
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white,
                                          ),
                                        )
                                      : Text(l10n.save),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validate(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordTooShort;
    return null;
  }
}
