import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'register_screen.dart';
import 'widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    // Controllers hold native resources and listeners; not disposing them leaks
    // memory every time the screen is destroyed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Dismiss the keyboard so the error or the next screen is not covered.
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // The dark scaffold shows through above the white sheet, so the header
      // colour continues behind the status bar.
      backgroundColor: AppColors.dark,
      body: Column(
        children: [
          AuthHeader(title: l10n.logIn, subtitle: l10n.loginSubtitle),
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
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (value) => _validatePassword(value, l10n),
                        ),
                        const SizedBox(height: 16),
                        _RememberRow(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v),
                        ),
                        const SizedBox(height: 24),

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
                                  // Disabling during the request stops a double
                                  // tap firing two logins.
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
                                      : Text(l10n.logIn.toUpperCase()),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                        _SignUpPrompt(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
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
    );
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.emailRequired;
    // Deliberately loose: something@something.something. Strict email regexes
    // reject valid addresses more often than they catch typos.
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

class _RememberRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RememberRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Both sides are Flexible so a long translation shrinks rather than
    // overflowing — Arabic and larger accessibility text sizes both need it.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          // Tapping the label should toggle the box too — a 24px target alone
          // is below the minimum for comfortable touch.
          child: InkWell(
            onTap: () => onChanged(!value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: value,
                    onChanged: (v) => onChanged(v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.rememberMe,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => AppRoutes.openForgotPassword(context),
            child: Text(l10n.forgotPassword, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _SignUpPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Wrap rather than Row: if the question and the link cannot sit on one
    // line — a longer translation, or a large text scale — they stack instead
    // of overflowing.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.dontHaveAccount,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n.signUp,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
