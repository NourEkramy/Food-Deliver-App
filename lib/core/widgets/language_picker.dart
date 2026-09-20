import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../locale/locale_cubit.dart';
import '../theme/app_colors.dart';

/// Offers the app's languages, plus "follow the device".
///
/// The language names are deliberately not translated — English stays
/// "English" and Arabic stays "العربية" in both locales. Someone who cannot
/// read the current language still needs to recognise their own.
Future<void> showLanguagePicker(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final cubit = context.read<LocaleCubit>();
  final current = cubit.state;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      Widget option(String label, Locale? locale) {
        final selected = current?.languageCode == locale?.languageCode;

        return ListTile(
          title: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: selected
              ? const Icon(Icons.check, color: AppColors.primary)
              : null,
          onTap: () {
            cubit.select(locale);
            Navigator.of(sheetContext).pop();
          },
        );
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  const Icon(Icons.language, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            option(l10n.languageSystem, null),
            option(l10n.languageEnglish, const Locale('en')),
            option(l10n.languageArabic, const Locale('ar')),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
