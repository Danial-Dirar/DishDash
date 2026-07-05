import 'package:flutter/material.dart';

/// Central brand palette so every screen shares one consistent look.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFF7931E);

  static const Color success = Color(0xFF2E9E5B);
  static const Color info = Color(0xFF3A7BD5);
  static const Color warning = Color(0xFFE8A33D);
  static const Color danger = Color(0xFFE05252);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Surface color that adapts to the current theme brightness.
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E1E1E)
      : Colors.white;

  static Color scaffold(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF121212)
      : const Color(0xFFF6F7F9);

  static Color subtleText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.grey[400]!
      : Colors.grey[600]!;
}
