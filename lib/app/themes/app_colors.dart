import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFE53935); // Rouge CashOut
  static const Color secondary = Color(0xFF263238); // Bleu nuit/Gris foncé
  
  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color pending = Color(0xFFFB8C00);
  static const Color error = Color(0xFFD32F2F);
  
  // Status Specific
  static const Color statusPending = Color(0xFFFB8C00);
  static const Color statusValidated = Color(0xFF43A047);
  static const Color statusRejected = Color(0xFFD32F2F);
  static const Color statusCancelled = Color(0xFF757575);
  
  // Status Backgrounds
  static const Color statusPendingBg = Color(0xFFFFF3E0);
  static const Color statusValidatedBg = Color(0xFFE8F5E9);
  static const Color statusRejectedBg = Color(0xFFFFEBEE);
  static const Color statusCancelledBg = Color(0xFFF5F5F5);

  // Backgrounds
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color shadowDark = Color(0x1A000000);
  
  // Texts
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
