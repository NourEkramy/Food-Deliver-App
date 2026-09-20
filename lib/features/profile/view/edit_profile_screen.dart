import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'profile_screen.dart' show ProfileAvatar;

/// Edits the display name.
///
/// That is genuinely all there is to edit. The API stores an email, a password
/// and a user code; it offers no name field, and no way to change an email.
/// The password has its own screen, because changing one is a deliberate act
/// rather than something to bundle into saving a name.
///
/// The design's photo, phone number and bio have no API fields either.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Pre-filled so the user edits rather than retypes.
    _nameController = TextEditingController(
      text: context.read<AuthCubit>().state.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileCubit>().saveName(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final email = context.select<AuthCubit, String>(
      (cubit) => cubit.state.email ?? '',
    );

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          current.outcome == ProfileOutcome.nameSaved,
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
                          // Rebuilds as they type, so the initials update live.
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
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _save(),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? l10n.nameRequired
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.nameStoredLocally,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.hint,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Shown, not editable: a field the user could type into
                        // but never change would be worse than none at all.
                        _ReadOnlyField(
                          label: l10n.email,
                          value: email,
                          note: l10n.emailCannotChange,
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<ProfileCubit, ProfileState>(
                          builder: (context, state) => ElevatedButton(
                            onPressed: state.isBusy ? null : _save,
                            child: Text(l10n.save),
                          ),
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
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final String note;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.hint, fontSize: 14),
                ),
              ),
              const Icon(Icons.lock_outline, size: 16, color: AppColors.hint),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(note, style: const TextStyle(fontSize: 12, color: AppColors.hint)),
      ],
    );
  }
}
