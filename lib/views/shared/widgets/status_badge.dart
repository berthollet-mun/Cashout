// ================================
// 📁 lib/views/shared/widgets/status_badge.dart
// ================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/themes/app_colors.dart';
import '../../../core/utils/helpers.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool   large;

  const StatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color   = _getColor();
    final bgColor = _getBgColor();
    final label   = Helpers.statusLabel(status);
    final emoji   = Helpers.statusEmoji(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16.w : 10.w,
        vertical:   large ? 8.h  : 4.h,
      ),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(large ? 10.r : 20.r),
        border:       Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: large ? 16.sp : 12.sp)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color:      color,
              fontSize:   large ? 14.sp : 11.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'pending':   return AppColors.statusPending;
      case 'validated': return AppColors.statusValidated;
      case 'rejected':  return AppColors.statusRejected;
      case 'cancelled': return AppColors.statusCancelled;
      default:          return AppColors.textSecondary;
    }
  }

  Color _getBgColor() {
    switch (status) {
      case 'pending':   return AppColors.statusPendingBg;
      case 'validated': return AppColors.statusValidatedBg;
      case 'rejected':  return AppColors.statusRejectedBg;
      case 'cancelled': return AppColors.statusCancelledBg;
      default:          return AppColors.surfaceVariant;
    }
  }
}