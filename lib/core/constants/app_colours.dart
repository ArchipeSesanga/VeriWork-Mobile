import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color.fromARGB(255, 66, 98, 167); //primary blue
  static const primaryLight = Color(0xFFF8F9FF); // Light background

  // Status Colors
  static const success = Color(0xFF10B981); // Green (verified)
  static const warning = Color.fromARGB(255, 214, 10, 10);
  static const error = Color(0xFFEF4444); // Red (rejected)
  static const pending = Color.fromARGB(255, 238, 202, 1); // Yellow (pending)

  // Neutral Colors
  static const textPrimary = Color(0xFF1A1A1A); // Dark text
  static const textSecondary = Color(0xFF6B7280); // Gray text
  static const border = Color(0xFFE5E7EB); // Border color
  static const background = Colors.white; // Background
}
