import 'package:flutter/material.dart';

/// Semantic color constants shared across the app.
/// Theme-brand colors (primary, secondary, etc.) come from [ColorScheme].
/// These are for status/category colors that stay fixed regardless of theme.
abstract final class AppColors {
  static const readingBlue = Color(0xFF1A6FA8);
  static const readingBlueContainer = Color(0xFFDCF0FF);

  static const completedGreen = Color(0xFF1E8040);
  static const completedGreenContainer = Color(0xFFDCF5E4);

  static const wishlistAmber = Color(0xFFB8740A);

  static const sessionPurple = Color(0xFF5E35B1);
  static const sessionPurpleContainer = Color(0xFFEDE7F6);

  static const suggestionsPurple = Color(0xFF7E5EA8);

  static const starYellow = Color(0xFFE8A020);
  static const starYellowContainer = Color(0xFFFFF8DC);

  static const pagesTeal = Color(0xFF00838F);
  static const pagesTealContainer = Color(0xFFE0F7FA);

  static const favoritesContainer = Color(0xFFFFE8F0);

  /// Returns the semantic status color for a book status string.
  static Color forStatus(String status) => switch (status) {
    'Reading'      => AppColors.readingBlue,
    'Already Read' => AppColors.completedGreen,
    'Wishlist'     => AppColors.wishlistAmber,
    _              => const Color(0xFF9E9E9E),
  };
}
