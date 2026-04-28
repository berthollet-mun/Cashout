// ================================
// 📁 lib/views/shared/widgets/custom_button.dart
// Bouton personnalisé réutilisable
// ================================

import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final String? text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? prefixIcon;
  final bool isOutlined;
  final Color? color;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;

  const CustomButton({
    Key? key,
    this.label = '',
    this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.prefixIcon,
    this.isOutlined = false,
    this.color,
    this.width,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocked = isLoading || isDisabled;
    final resolvedLabel = text ?? label;
    final resolvedIcon = prefixIcon ?? icon;
    final resolvedBg = isOutlined
        ? Colors.transparent
        : (color ?? backgroundColor ?? AppColors.primary);
    final resolvedFg = foregroundColor ?? (isOutlined ? (color ?? AppColors.primary) : Colors.white);
    final resolvedBorder = isOutlined ? (color ?? AppColors.primary) : Colors.transparent;

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLocked ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    resolvedFg,
                  ),
                ),
              )
            : (resolvedIcon != null ? Icon(resolvedIcon) : const SizedBox.shrink()),
        label: Text(
          isLoading ? 'Chargement...' : resolvedLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: resolvedFg,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[400] : resolvedBg,
          foregroundColor: resolvedFg,
          side: BorderSide(color: resolvedBorder, width: isOutlined ? 1.6 : 0),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: isLocked ? 0 : 2,
          disabledBackgroundColor: Colors.grey[400],
        ),
      ),
    );
  }
}

/// Bouton secondaire
class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;

  const CustomOutlinedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.borderColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(
          isLoading ? 'Chargement...' : label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppColors.primary,
            width: 2,
          ),
          foregroundColor: textColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Bouton texte simple
class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final TextStyle? textStyle;

  const CustomTextButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: textStyle ??
            TextStyle(
              color: textColor ?? AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
