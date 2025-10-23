import 'package:flutter/material.dart';
import 'app_colours.dart';

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Unbounded',
  );

  static const heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontFamily: 'Roboto',
  );
}
