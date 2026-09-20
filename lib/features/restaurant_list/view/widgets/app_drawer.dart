import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../routes.dart';
import '../../../auth/cubit/auth_cubit.dart';

/// The side menu behind the home screen's menu button.
///
/// Currently it holds the signed-in user and logout — which is where the design
/// puts logout, and replaces the temporary button that sat above the search
/// field. The remaining destinations (My Orders, Profile, Addresses, Payment)
/// get added as those screens are built.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthCubit>().state;

    return Drawer(
      backgroundColor: AppColors.dark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: AppColors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          auth.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((auth.email ?? '').isNotEmpty)
                          Text(
                            auth.email!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.hint,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.white),
              title: Text(
                l10n.personalInfo,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.openProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: AppColors.white,
              ),
              title: Text(
                l10n.myAddresses,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.openAddresses(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.white),
              title: Text(
                l10n.payment,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.openPayment(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.white,
              ),
              title: Text(
                l10n.myOrders,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.openOrders(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.white),
              title: Text(
                l10n.language,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
              onTap: () {
                // The Navigator's own context, captured before the drawer
                // closes: this tile's context is torn down by the pop, and the
                // sheet outlives it.
                final navigator = Navigator.of(context);
                navigator.pop();
                showLanguagePicker(navigator.context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.white),
              title: Text(
                l10n.logout,
                style: const TextStyle(color: AppColors.white, fontSize: 15),
              ),
              onTap: () {
                // Close the drawer first: AuthGate is about to replace the
                // screen underneath it, and an open drawer would be orphaned.
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
