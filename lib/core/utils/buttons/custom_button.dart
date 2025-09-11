import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/constants/app_typography.dart';
import 'package:repair_cms/core/enums/app_button_type.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? disabledBackgroundColor; // Add this
  final Color? disabledForegroundColor; // Add this
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final Size? maximumSize;
  final double? borderRadius;
  final double? borderWidth;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final double? elevation;
  final TextStyle? textStyle;
  final bool expandWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.disabledBackgroundColor, // Add this parameter
    this.disabledForegroundColor, // Add this parameter
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    this.minimumSize = const Size(120, 56),
    this.maximumSize,
    this.borderRadius = 8.0,
    this.borderWidth = 2.0,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 56.0,
    this.elevation = 2.0,
    this.textStyle,
    this.expandWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final primaryColor = backgroundColor ?? AppColors.primary;

    // Use disabled colors if button is disabled
    final buttonBackgroundColor = isDisabled
        ? (disabledBackgroundColor ?? AppColors.disabledButtonColor)
        : (type == AppButtonType.filled
              ? (backgroundColor ?? AppColors.primary)
              : (backgroundColor ?? AppColors.whiteColor));

    final buttonForegroundColor = isDisabled
        ? (disabledForegroundColor ?? AppColors.whiteColor)
        : (type == AppButtonType.filled
              ? (foregroundColor ?? AppColors.whiteColor)
              : (foregroundColor ?? AppColors.blackColor));

    final buttonBorderColor = type == AppButtonType.outlined
        ? (isDisabled
              ? (disabledBackgroundColor ?? AppColors.disabledButtonColor)
              : (borderColor ?? AppColors.blackColor))
        : Colors.transparent;

    final finalTextStyle = textStyle ?? AppTypography.primaryButtonTextStyle;

    Widget buttonContent = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                type == AppButtonType.filled ? AppColors.whiteColor : AppColors.whiteColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(text, style: finalTextStyle, textAlign: TextAlign.center),
              if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon!],
            ],
          );

    Widget button;

    if (type == AppButtonType.filled) {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonForegroundColor,
          padding: padding,
          minimumSize: minimumSize,
          maximumSize: maximumSize,
          disabledBackgroundColor: AppColors.disabledButtonColor,
          elevation: elevation,
          shadowColor: primaryColor.withValues(alpha: 0.3),
          shape: StadiumBorder(),
          textStyle: finalTextStyle,
        ),
        child: buttonContent,
      );
    } else {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonForegroundColor,
          padding: padding,
          minimumSize: minimumSize,
          maximumSize: maximumSize,
          side: BorderSide(color: buttonBorderColor, width: borderWidth ?? 2.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 8.0)),
          textStyle: finalTextStyle,
        ),
        child: buttonContent,
      );
    }

    return SizedBox(width: isFullWidth ? double.infinity : width, height: height, child: button);
  }
}
