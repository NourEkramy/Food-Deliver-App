import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The − N + control used on the item screen and in the cart.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool onDark;

  /// Below this the decrement button is disabled. The cart passes 0 so that
  /// stepping down from 1 removes the line instead of sticking at 1.
  final int minimum;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.onDark = false,
    this.minimum = 1,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = onDark ? AppColors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: onDark ? AppColors.dark : AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: quantity > minimum ? onDecrement : null,
            onDark: onDark,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 34),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                color: foreground,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrement, onDark: onDark),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool onDark;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.onDark,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: onDark ? Colors.white12 : AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 30,
          width: 30,
          child: Icon(
            icon,
            size: 16,
            color: enabled
                ? (onDark ? AppColors.white : AppColors.textPrimary)
                : AppColors.hint,
          ),
        ),
      ),
    );
  }
}
