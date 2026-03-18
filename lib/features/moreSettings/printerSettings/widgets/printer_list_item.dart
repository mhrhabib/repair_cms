import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/printer_config_model.dart';

class PrinterListItem extends StatelessWidget {
  final PrinterConfigModel printer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const PrinterListItem({
    super.key,
    required this.printer,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: printer.isDefault
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.print_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        printer.printerModel ?? printer.printerBrand,
                        style: AppTypography.sfProText15.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (printer.isDefault) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'IP: ${printer.ipAddress}',
                  style: AppTypography.sfProText15.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
                  ),
                ),
                if (printer.printerType == 'label' && printer.labelSize != null)
                  Text(
                    'Label Size: ${printer.labelSize!.width} x ${printer.labelSize!.height} mm',
                    style: AppTypography.sfProText15.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                if (printer.printerType == 'thermal' && printer.paperWidth != null)
                  Text(
                    'Paper Width: ${printer.paperWidth} mm',
                    style: AppTypography.sfProText15.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz_rounded,
                color: AppColors.fontSecondaryColor.withValues(alpha: 0.6),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'default') {
                  onSetDefault();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                if (!printer.isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
