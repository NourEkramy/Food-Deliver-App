import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Every remote image in the app.
///
/// Wraps [CachedNetworkImage] rather than `Image.network`, which keeps images
/// in memory only — scrolling a list away and back re-downloaded every photo.
/// This caches to disk, so a dish fetched once stays fetched.
///
/// It also gives the whole app one loading state and one fallback, instead of
/// each screen inventing its own.
class AppNetworkImage extends StatelessWidget {
  final String? url;

  /// Shown while loading, and when there is no image or it fails to load.
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.restaurant,
    this.fallbackIconSize = 32,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _Fallback(icon: fallbackIcon, size: fallbackIconSize);
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      // A flat block rather than a spinner: a grid of spinners is noisier than
      // a grid of placeholders, and the image usually arrives quickly.
      placeholder: (context, _) =>
          const ColoredBox(color: AppColors.surfaceGrey),
      errorWidget: (context, _, __) =>
          _Fallback(icon: fallbackIcon, size: fallbackIconSize),
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }
}

class _Fallback extends StatelessWidget {
  final IconData icon;
  final double size;

  const _Fallback({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceGrey,
      child: Center(
        child: Icon(icon, size: size, color: AppColors.hint),
      ),
    );
  }
}
