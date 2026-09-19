import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows a failed request's message above the form's submit button.
///
/// Extracted once Login and Sign Up both needed it; every remaining form screen
/// (Add Card, Add Address, Edit Profile) will want the same treatment.
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // A tinted block rather than bare red text: it reads as a distinct
        // region so it is noticed, without shouting.
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
