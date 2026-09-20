import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'profile_screen.dart' show ProfileAvatar;

/// Edits the name and email, and sets a new password.
///
/// The design also offers a photo, a phone number and a bio. The API stores
/// none of those, so they are left out. The password field is not in the design
/// either, but the endpoint requires `NewPassword` on every update — there is
/// no way to change an email without also setting a password.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-filled from the session so the user edits rather than retypes.
    final auth = context.read<AuthCubit>().state;
    _nameController = TextEditingController(text: auth.name ?? '');
    _emailController = TextEditingController(text: auth.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileCubit>().save(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      newPassword: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => current.justSaved,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: l10n.editProfile),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: ValueListenableBuilder(
                            valueListenable: _nameController,
                            builder: (context, value, _) => ProfileAvatar(
                              name: value.text.isEmpty
                                  ? context.read<AuthCubit>().state.displayName
                                  : value.text,
                              size: 104,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AppTextField(
                          label: l10n.fullName,
                          hint: l10n.nameHint,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          validator: (value) => (value?.trim().isEmpty ?? true)
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
                          label: l10n.newPassword,
                          hint: '••••••••••',
                          controller: _passwordController,
                          obscure: true,
                          validator: (value) => _validatePassword(value, l10n),
                        ),
                        const SizedBox(height: 8),
                        // Explains an otherwise baffling requirement rather
                        // than letting the server reject the save.
                        Text(
                          l10n.passwordNeededToSave,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.hint,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: l10n.confirmNewPassword,
                          hint: '••••••••••',
                          controller: _confirmController,
                          obscure: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _save(),
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
                                  onPressed: state.isSaving ? null : _save,
                                  child: state.isSaving
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
