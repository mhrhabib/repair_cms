import 'dart:math' as math;
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/dashboard/dashboard_screen.dart';
import 'package:repair_cms/features/jobBooking/screens/job_booking_first_screen.dart';
import 'package:repair_cms/features/messeges/demo_conversation_screen.dart';
import 'package:repair_cms/features/messeges/messges_screen.dart';
import 'package:repair_cms/features/messeges/screens/socket_test_screen.dart';
import 'package:repair_cms/features/moreSettings/more_settings_screen.dart';
import 'package:repair_cms/features/myJobs/my_jobs_screen.dart';
import 'package:repair_cms/features/scanner/job_scanner_screen.dart';
import 'package:solar_icons/solar_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MyJobsScreen(),
    const MessagesScreen(),
    const SocketTestScreen(),
  ];

  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _rotationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (0.125 * 360° = 45°)
    ).animate(CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        _rotationController.forward();
      } else {
        _animationController.reverse();
        _rotationController.reverse();
      }
    });
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
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, SolarIconsOutline.pinCircle, 'Home'),
              _buildBottomNavItem(1, SolarIconsOutline.caseRoundMinimalistic, 'My Jobs'),
              // Empty container to balance the space for the center button
              SizedBox(width: 56.w, height: 56.h),
              _buildBottomNavItem(2, SolarIconsOutline.chatUnread, 'Messages'),
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
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 60.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade400, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTypography.fontSize10.copyWith(
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: AppColors.whiteColor, width: 4.w),
        ),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 4.2 * math.pi,
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
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
    setState(() {
      _currentIndex = index;
    });
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
                        onTap: () {
                          // Handle New Job action
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobBookingFirstScreen()));
                          debugPrint('New Job tapped');
                          _toggleExpansion();
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Barcode Scanner Button
                      _buildExpandableButton(
                        icon: FontAwesomeIcons.barcode,
                        label: 'Barcode Scanner',
                        backgroundColor: const Color(0xFF2589F6),
                        onTap: () {
                          _toggleExpansion();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JobScannerScreen(isBarcodeMode: true)),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // QR Scanner Button
                      _buildExpandableButton(
                        icon: SolarIconsBold.qrCode,
                        label: 'QR Scanner',
                        backgroundColor: const Color(0xFF2589F6),
                        onTap: () {
                          _toggleExpansion();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JobScannerScreen(isBarcodeMode: false)),
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Demo Conversation Button
                      _buildExpandableButton(
                        icon: SolarIconsBold.chatRoundDots,
                        label: 'Demo Chat',
                        backgroundColor: const Color(0xFF10B981),
                        onTap: () {
                          _toggleExpansion();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DemoConversationScreen()),
                          );
                        },
                      ),
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
            Text(label, style: AppTypography.fontSize20.copyWith(color: Colors.white)),
            SizedBox(width: 8.w),
            Container(
              height: 64.w,
              width: 64.w,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(color: backgroundColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
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
