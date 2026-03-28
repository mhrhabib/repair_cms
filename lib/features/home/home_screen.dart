import 'dart:math' as math;
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/dashboard/dashboard_screen.dart';
import 'package:repair_cms/features/jobBooking/screens/job_booking_first_screen.dart';
import 'package:repair_cms/features/messeges/messages_screen.dart';
import 'package:repair_cms/features/moreSettings/more_settings_screen.dart';
import 'package:repair_cms/features/myJobs/screens/my_jobs_screen.dart';
import 'package:repair_cms/features/scanner/job_scanner_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final String? initialStatus;
  const HomeScreen({super.key, this.initialIndex = 0, this.initialStatus});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late List<Widget> _screens;

  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const DashboardScreen(),
      MyJobsScreen(initialStatus: widget.initialStatus),
      const MessagesScreen(),
      const MoreSettingsScreen(),
    ];

    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _rotationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _expandAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );

      _rotationAnimation =
          Tween<double>(
            begin: 0.0,
            end: 0.125, // 45 degrees (0.125 * 360° = 45°)
          ).animate(
            CurvedAnimation(
              parent: _rotationController,
              curve: Curves.easeInOut,
            ),
          );

      debugPrint(
        '✅ [HomeScreen] Animation controllers initialized successfully',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [HomeScreen] Error initializing animations: $e');
      debugPrint('📋 [HomeScreen] Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    try {
      _animationController.dispose();
      _rotationController.dispose();
      debugPrint('✅ [HomeScreen] Animation controllers disposed successfully');
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error disposing animations: $e');
    }
    super.dispose();
  }

  void _toggleExpansion() {
    if (!mounted) return;

    try {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _animationController.forward();
          _rotationController.forward();
          debugPrint('🔄 [HomeScreen] Expanding FAB menu');
        } else {
          _animationController.reverse();
          _rotationController.reverse();
          debugPrint('🔄 [HomeScreen] Collapsing FAB menu');
        }
      });
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error toggling expansion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          // Apply backdrop filter only when expanded
          if (_isExpanded)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          // Position the expandable FAB above all content
          _buildExpandableFAB(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, SolarIconsOutline.pieChart, 'Home'),
              _buildBottomNavItem(1, SolarIconsOutline.suitcaseTag, 'Jobs'),
              // Empty container to balance the space for the center button
              SizedBox(width: 56.w, height: 56.h),
              _buildBottomNavItem(2, SolarIconsOutline.dialog2, 'Messages'),
              _buildBottomNavItem(3, SolarIconsOutline.menuDots, 'More'),
            ],
          ),
        ),
        // Elevated center button
        Positioned(
          top: -20.h, // This makes the button appear above the navigation bar
          child: _buildCenterAddButton(),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    return _BottomNavItem(
      index: index,
      icon: icon,
      label: label,
      isSelected: _currentIndex == index,
      onTap: () => _onItemTapped(index),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        width: 64.w, // Slightly larger for emphasis
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,

          border: Border.all(color: AppColors.whiteColor, width: 4.w),
        ),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 4.2 * math.pi,
              child: Icon(
                _isExpanded ? FontAwesomeIcons.xmark : FontAwesomeIcons.plus,
                color: AppColors.whiteColor,
                size: 32.sp,
                weight: 800,
                fill: 0.8,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (!mounted) return;

    try {
      // Remove focus from any focused input first so taps aren't consumed by focus changes
      if (mounted) {
        FocusScope.of(context).unfocus();
      }

      setState(() {
        _currentIndex = index;
        // When tapping the Jobs tab manually, ensure no initial status persists
        if (index == 1) {
          _screens[1] = const MyJobsScreen();
        }
      });

      debugPrint('📍 [HomeScreen] Navigated to tab: $index');
    } catch (e) {
      debugPrint('❌ [HomeScreen] Error changing tab: $e');
    }
  }

  Widget _buildExpandableFAB() {
    return Positioned(
      bottom: 20.h, // Position above the navigation bar
      right: 20.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expandable buttons
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _expandAnimation.value,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // QR Scanner Button
                      _buildExpandableButton(
                        icon: SolarIconsBold.caseRoundMinimalistic,
                        label: 'New Job',
                        backgroundColor: const Color(0xFF2589F6),
                        onTap: () async {
                          if (!mounted) return;

                          try {
                            debugPrint('🚀 [HomeScreen] Navigating to New Job');
                            _toggleExpansion();

                            await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        JobBookingFirstScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(
                                        begin: begin,
                                        end: end,
                                      ).chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(
                                        tween,
                                      );
                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                              ),
                            );

                            debugPrint(
                              '✅ [HomeScreen] Returned from New Job screen',
                            );
                          } catch (e) {
                            debugPrint(
                              '❌ [HomeScreen] Error navigating to New Job: $e',
                            );
                          }
                        },
                      ),

                      // SizedBox(height: 16.h),

                      // Barcode Scanner Button
                      // _buildExpandableButton(
                      //   icon: FontAwesomeIcons.barcode,
                      //   label: 'Barcode Scanner',
                      //   backgroundColor: const Color(0xFF2589F6),
                      //   onTap: () async {
                      //     if (!mounted) return;

                      //     try {
                      //       debugPrint(
                      //         '🚀 [HomeScreen] Navigating to Barcode Scanner',
                      //       );
                      //       _toggleExpansion();

                      //       await Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) =>
                      //               const JobScannerScreen(isBarcodeMode: true),
                      //         ),
                      //       );

                      //       debugPrint(
                      //         '✅ [HomeScreen] Returned from Barcode Scanner',
                      //       );
                      //     } catch (e) {
                      //       debugPrint(
                      //         '❌ [HomeScreen] Error navigating to Barcode Scanner: $e',
                      //       );
                      //     }
                      //   },
                      // ),
                      // SizedBox(height: 16.h),

                      // QR Scanner Button
                      _buildExpandableButton(
                        icon: SolarIconsBold.qrCode,
                        label: 'QR Scanner',
                        backgroundColor: const Color(0xFF2589F6),
                        onTap: () async {
                          if (!mounted) return;

                          try {
                            debugPrint(
                              '🚀 [HomeScreen] Navigating to QR Scanner',
                            );
                            _toggleExpansion();

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const JobScannerScreen(
                                  isBarcodeMode: false,
                                ),
                              ),
                            );

                            debugPrint(
                              '✅ [HomeScreen] Returned from QR Scanner',
                            );
                          } catch (e) {
                            debugPrint(
                              '❌ [HomeScreen] Error navigating to QR Scanner: $e',
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Demo Conversation Button
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        // decoration: BoxDecoration(
        //   color: backgroundColor,
        //   borderRadius: BorderRadius.circular(30.r),
        //   boxShadow: [
        //     BoxShadow(color: backgroundColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
        //   ],
        // ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.fontSize20.copyWith(color: Colors.white),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 64.w,
              width: 64.w,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem>
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
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(opacity: _opacityAnimation.value, child: child);
        },
        child: SizedBox(
          width: 68.w,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? const Color(0xFFF7F7F8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(46.r),
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.whiteColor
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: widget.isSelected
                        ? [
                            const BoxShadow(
                              color: Color.fromARGB(28, 116, 115, 115),
                              blurRadius: 2,
                              offset: Offset(0, 0),
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? AppColors.primary
                          : AppColors.lightFontColor,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  widget.label,
                  style: AppTypography.fontSize10.copyWith(
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.lightFontColor,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
