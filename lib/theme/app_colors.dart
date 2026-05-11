import 'package:flutter/material.dart';

/// Semantic color constants shared across the app.
/// Theme-brand colors (primary, secondary, etc.) come from [ColorScheme].
/// These are for status/category colors that stay fixed regardless of theme.
abstract final class AppColors {
  static const readingBlue = Color(0xFF1A6FA8);
  static const readingBlueContainer = Color(0xFFDCF0FF);

  static const completedGreen = Color(0xFF1E8040);
  static const completedGreenContainer = Color(0xFFDCF5E4);

  static const sessionPurple = Color(0xFF5E35B1);
  static const sessionPurpleContainer = Color(0xFFEDE7F6);

  static const suggestionsPurple = Color(0xFF7E5EA8);

  static const starYellow = Color(0xFFE8A020);
}
