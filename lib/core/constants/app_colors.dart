import 'package:flutter/material.dart';

/// Centralized color constants for TurfSync app.
/// Supports both light and dark theme palettes.
class AppColors {
  AppColors._();

  // ─── Primary Palette ───
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  // ─── Secondary Palette ───
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeLight = Color(0xFFFFB74D);

  // ─── Surface Colors ───
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2C);

  // ─── Text Colors ───
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // ─── Status Colors ───
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // ─── Booking Status Colors ───
  static const Color pendingColor = Color(0xFFFFA726);
  static const Color approvedColor = Color(0xFF66BB6A);
  static const Color rejectedColor = Color(0xFFEF5350);

  // ─── Slot Colors ───
  static const Color availableSlot = Color(0xFFC8E6C9);
  static const Color bookedSlot = Color(0xFFFFCDD2);
  static const Color selectedSlot = Color(0xFF81C784);
}
