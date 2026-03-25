import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/printer_config_model.dart';

class PrinterListItem extends StatefulWidget {
  final PrinterConfigModel printer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final bool isDefault;

  const PrinterListItem({
    super.key,
    required this.printer,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    required this.isDefault,
  });

  @override
  State<PrinterListItem> createState() => _PrinterListItemState();
}

class _PrinterListItemState extends State<PrinterListItem>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _menuController;
  late Animation<double> _expandAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

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
        border: widget.isDefault
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: widget.isDefault
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.fontSecondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  SolarIconsBold.printer,
                  color: widget.isDefault
                      ? AppColors.primary
                      : AppColors.fontSecondaryColor,
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
                            widget.printer.printerModel ??
                                widget.printer.printerBrand,
                            style: AppTypography.sfProText15.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.printer.isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
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
                      'IP: ${widget.printer.ipAddress}',
                      style: AppTypography.sfProText15.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.fontSecondaryColor.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    if (widget.printer.printerType == 'label' &&
                        widget.printer.labelSize != null)
                      Text(
                        'Label Size: ${widget.printer.labelSize!.width} x ${widget.printer.labelSize!.height} mm',
                        style: AppTypography.sfProText15.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.fontSecondaryColor.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    if (widget.printer.printerType == 'thermal' &&
                        widget.printer.paperWidth != null)
                      Text(
                        'Paper Width: ${widget.printer.paperWidth} mm',
                        style: AppTypography.sfProText15.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.fontSecondaryColor.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              CustomNavButton(
                onPressed: _toggleMenu,
                icon: _isMenuOpen
                    ? Icons.close_rounded
                    : Icons.more_horiz_rounded,
                size: 20.sp,
                width: 38.w,
                height: 38.w,
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axis: Axis.horizontal,
            axisAlignment: 1.0,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                margin: EdgeInsets.only(right: 46.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.kBg,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomNavButton(
                      onPressed: () {
                        _toggleMenu();
                        widget.onEdit();
                      },
                      icon: Icons.edit_outlined,
                      size: 18.sp,
                      width: 36.w,
                      height: 36.w,
                    ),
                    if (!widget.printer.isDefault) ...[
                      SizedBox(width: 8.w),
                      CustomNavButton(
                        onPressed: () {
                          _toggleMenu();
                          widget.onSetDefault();
                        },
                        icon: Icons.check_circle_outline,
                        size: 18.sp,
                        width: 36.w,
                        height: 36.w,
                      ),
                    ],
                    SizedBox(width: 8.w),
                    CustomNavButton(
                      onPressed: () {
                        _toggleMenu();
                        widget.onDelete();
                      },
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      size: 18.sp,
                      width: 36.w,
                      height: 36.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
