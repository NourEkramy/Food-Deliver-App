import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A cuisine filter pill: circle avatar plus label.
///
/// The design pairs each category with a photo. The API has no category images
/// — cuisines arrive as bare strings like "Biryani" — so the circle holds a
/// neutral icon, which is also what the mockup itself shows as a placeholder.
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Material(
        color: selected ? AppColors.chipSelected : AppColors.white,
        borderRadius: BorderRadius.circular(40),
        // Unselected chips sit on white, so they need a shadow to separate
        // from the page; the selected one is carried by its fill.
        elevation: selected ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 20, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceGrey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 18,
                    color: AppColors.hint,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
