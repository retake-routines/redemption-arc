import 'package:flutter/material.dart';

abstract class AppColors {
  // ---- Primary (green for habits/health) ----
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryVariantLight = Color(0xFF388E3C);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  static const Color primaryDark = Color(0xFF66BB6A);
  static const Color primaryVariantDark = Color(0xFF2E7D32);
  static const Color onPrimaryDark = Color(0xFF000000);

  // ---- Secondary (teal accents) ----
  static const Color secondaryLight = Color(0xFF009688);
  static const Color secondaryVariantLight = Color(0xFF00796B);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);

  static const Color secondaryDark = Color(0xFF4DB6AC);
  static const Color secondaryVariantDark = Color(0xFF00897B);
  static const Color onSecondaryDark = Color(0xFF000000);

  // ---- Surface & Background ----
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F7F5);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onBackgroundLight = Color(0xFF1C1B1F);

  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);

  // ---- Error ----
  static const Color errorLight = Color(0xFFB3261E);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorDark = Color(0xFFF2B8B5);
  static const Color onErrorDark = Color(0xFF601410);

  // ---- Streak / Fire ----
  static const Color streak = Color(0xFFFF9800);
  static const Color streakGold = Color(0xFFFFD700);
  static const Color streakIntense = Color(0xFFFF5722);

  // ---- Completion ----
  static const Color completed = Color(0xFF2E7D32);
  static const Color completedLight = Color(0xFFC8E6C9);

  // ---- Calendar heatmap ----
  static const Color heatmapEmpty = Color(0xFFEEEEEE);
  static const Color heatmapEmptyDark = Color(0xFF2C2C2C);
  static const Color heatmapLevel1 = Color(0xFFC8E6C9);
  static const Color heatmapLevel2 = Color(0xFF81C784);
  static const Color heatmapLevel3 = Color(0xFF4CAF50);
  static const Color heatmapLevel4 = Color(0xFF2E7D32);

  // ---- Misc ----
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF383838);
}
