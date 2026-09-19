import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The top bar used across the inner screens: a circular back button, a
/// centred title, and optional trailing content.
///
/// Not an AppBar: the design's back button is a filled circle inset from the
/// edge, which AppBar's leading slot cannot size or pad the same way.
class ScreenHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  /// Dark screens invert the colours instead of restating them at each call.
  final bool onDark;

  const ScreenHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = onDark ? AppColors.white : AppColors.textPrimary;
    final circle = onDark ? Colors.white12 : AppColors.surfaceGrey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          Material(
            color: circle,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: SizedBox(
                height: 45,
                width: 45,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: foreground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
