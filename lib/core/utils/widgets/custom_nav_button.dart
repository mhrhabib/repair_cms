import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_cms/core/constants/app_colors.dart';

class CustomNavButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double? size;
  final double? width;
  final double? height;
  final Color? iconColor;
  final Color? backgroundColor;

  const CustomNavButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size,
    this.width,
    this.height,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  State<CustomNavButton> createState() => _CustomNavButtonState();
}

class _CustomNavButtonState extends State<CustomNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    // Dissolve effect: ease-in opacity fade
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
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: widget.width ?? 42.w,
            height: widget.height ?? 42.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? const Color(0xFFF7F7F8),
              shape: BoxShape.circle,
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
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? AppColors.lightFontColor,
                size: widget.size ?? 24.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
