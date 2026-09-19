import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'widgets/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    // Everything is checked here, before any request goes out. The old screen
    // compared the passwords only after the button was pressed and showed the
    // mismatch in a SnackBar, which is easy to miss and easy to fire twice.
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
      _emailController.text.trim(),
      _passwordController.text,
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthCubit, AuthState>(
      // Fire only on the transition into a signed-in state, not on every
      // intermediate emit (isLoading flipping, errors clearing).
      listenWhen: (previous, current) =>
          !previous.isAuthenticated && current.isAuthenticated,
      listener: (context, state) {
        // MaterialApp installs a ScaffoldMessenger above the Navigator, so this
        // SnackBar outlives the pop below and is still visible on the screen
        // AuthGate swaps in.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.accountCreated)));

        // AuthGate has already replaced the root screen with the app, so
        // popping back to it reveals that rather than pushing anything new.
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: Column(
          children: [
            AuthHeader(
              title: l10n.signUpTitle,
              subtitle: l10n.signUpSubtitle,
              showBackButton: true,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            label: l10n.name,
                            hint: l10n.nameHint,
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            validator: (value) =>
                                (value?.trim().isEmpty ?? true)
                                ? l10n.nameRequired
                                : null,
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            label: l10n.email,
                            hint: l10n.emailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => _validateEmail(value, l10n),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            label: l10n.password,
                            hint: '••••••••••',
                            controller: _passwordController,
                            obscure: true,
                            validator: (value) =>
                                _validatePassword(value, l10n),
                          ),
                          const SizedBox(height: 24),
                          AppTextField(
                            label: l10n.retypePassword,
                            hint: '••••••••••',
                            controller: _confirmController,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            // Closes over the password controller so the two
                            // fields can be compared at validation time.
                            validator: (value) =>
                                value != _passwordController.text
                                ? l10n.passwordsDoNotMatch
                                : null,
                          ),
                          const SizedBox(height: 32),

                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (state.errorMessage != null) ...[
                                    ErrorBanner(message: state.errorMessage!),
                                    const SizedBox(height: 16),
                                  ],
                                  ElevatedButton(
                                    onPressed: state.isLoading ? null : _submit,
                                    child: state.isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : Text(l10n.signUp),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.emailRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return l10n.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordTooShort;
    return null;
  }
}
