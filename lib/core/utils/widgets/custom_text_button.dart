import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/constants/app_colors.dart';

class CustomTextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(opacity: _opacityAnimation.value, child: child);
        },
        child: Padding(
          padding: EdgeInsets.all(4.r), // room for shadow on all sides
          child: Container(
            width: widget.width ?? 82.w, // Figma: width 82
            height: widget.height ?? 42.h, // Figma: height 42
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(
                28.r,
              ), // Figma: border-radius 46px
              border: Border.all(
                color: AppColors.whiteColor, // Figma: border #FFFFFF
                width: 1, // Figma: border-width 1px
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    28,
                    116,
                    115,
                    115,
                  ), // Figma: #0000001C
                  blurRadius: 2, // Figma: blur 20px
                  offset: Offset(0, 0), // Figma: 0px 0px (no offset)
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: widget.fontWeight ?? FontWeight.w500,
                  fontSize: widget.fontSize ?? 16.sp,
                  height: 1.0,
                  letterSpacing: 0,
                  color: widget.textColor ?? const Color(0xFF71788F), // #71788F
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
