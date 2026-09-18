import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The dark navy panel at the top of every auth screen: Log In, Sign Up,
/// Forgot Password and Verification all share it.
///
/// The screen below it supplies the white sheet; this widget owns only the dark
/// area, its decorative fan, and the optional back button.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // A minimum height rather than a fixed one: at large accessibility text
    // scales the title and subtitle need more room, and a fixed height would
    // clip them. The Padding below is the Stack's only unpositioned child, so
    // it is what the Stack sizes itself to.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 235,
        minWidth: double.infinity,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The radiating lines in the top-left corner.
          Positioned.fill(child: CustomPaint(painter: const _FanPainter())),

          if (showBackButton)
            PositionedDirectional(
              top: 16,
              start: 24,
              child: SafeArea(
                child: _BackButton(onTap: () => Navigator.of(context).pop()),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 96, 24, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          height: 45,
          width: 45,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.dark,
          ),
        ),
      ),
    );
  }
}

/// Draws the quarter-circle fan of thin lines in the top-left corner.
///
/// The design ships this as a flat image, but drawing it keeps the app free of
/// a raster asset that would need three resolutions and would not recolour.
class _FanPainter extends CustomPainter {
  const _FanPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const origin = Offset(6, -18);
    const radius = 165.0;
    const lineCount = 26;

    final paint = Paint()
      ..color = AppColors.darkAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Sweep from pointing left-ish round to pointing down, so the fan opens
    // across the corner.
    const start = -math.pi * 0.08;
    const sweep = math.pi * 0.62;

    for (var i = 0; i <= lineCount; i++) {
      final angle = start + sweep * (i / lineCount);
      canvas.drawLine(
        origin,
        origin + Offset(math.cos(angle), math.sin(angle)) * radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FanPainter oldDelegate) => false;
}
