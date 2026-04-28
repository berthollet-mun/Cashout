import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get h1 => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        color: AppColors.textSecondary,
        fontFamily: 'Poppins',
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Poppins',
      );
}
