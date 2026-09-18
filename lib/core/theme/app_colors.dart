import 'package:flutter/material.dart';

/// Every colour in the app, sampled directly from the Figma screens.
///
/// Nothing outside this file should contain a raw `Color(0x...)` or a
/// `Colors.orange`. If a colour is needed that is not here, it belongs here
/// first — that is what keeps thirty-four screens looking like one app.
class AppColors {
  const AppColors._();

  /// Buttons, active states, prices, icons.
  static const Color primary = Color(0xFFFF7622);

  /// Dark panels: the login header, splash background, cart badge.
  static const Color dark = Color(0xFF121223);

  /// The faint radiating "fan" drawn on the dark auth header — barely lighter
  /// than [dark] itself.
  static const Color darkAccent = Color(0xFF1E1E2E);

  /// Headings and body copy.
  static const Color textPrimary = Color(0xFF181C2E);

  /// Small uppercase field labels (EMAIL, PASSWORD).
  static const Color textLabel = Color(0xFF32343E);

  /// Muted supporting copy ("Don't have an account?").
  static const Color textSecondary = Color(0xFF646982);

  /// Placeholder text inside inputs.
  static const Color hint = Color(0xFFA0A5BA);

  /// Text field background on the auth screens.
  static const Color inputFill = Color(0xFFF0F5FA);

  /// Search field and neutral surfaces on the home screen.
  static const Color surfaceGrey = Color(0xFFF6F6F6);

  /// The selected category pill on the home screen.
  static const Color chipSelected = Color(0xFFFFD27C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEBEBEB);
  static const Color error = Color(0xFFE04F5F);

  /// Social sign-in buttons.
  static const Color facebook = Color(0xFF395998);
  static const Color twitter = Color(0xFF169CE8);
  static const Color apple = Color(0xFF111B21);
}
