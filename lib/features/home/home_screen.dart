import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/dasboard/dashboard_screen.dart';
import 'package:repair_cms/features/messeges/messges_screen.dart';
import 'package:repair_cms/features/moreSettings/more_settings_screen.dart';
import 'package:repair_cms/features/myJobs/my_jobs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MyJobsScreen(),
    const MessgesScreen(),
    const MoreSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _screens[_currentIndex], bottomNavigationBar: _buildBottomNavigationBar());
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home, 'Home'),
              _buildBottomNavItem(1, Icons.work_outline, 'My Jobs'),
              // Empty container to balance the space for the center button
              Container(width: 56.w, height: 56.h),
              _buildBottomNavItem(2, Icons.message_outlined, 'Messages'),
              _buildBottomNavItem(3, Icons.more_horiz, 'More'),
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
      onTap: () {
        // Handle the add button action
        _showAddOptions(context);
      },
      child: Container(
        width: 64.w, // Slightly larger for emphasis
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          border: Border.all(color: AppColors.whiteColor, width: 4.w),
        ),
        child: Icon(Icons.add, color: AppColors.whiteColor, size: 32.sp),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(height: 24.h),
              Text('Create New', style: AppTypography.sfProHeadLineTextStyle28.copyWith(fontSize: 20.sp)),
              SizedBox(height: 24.h),
              _buildAddOptionItem(Icons.work_outline, 'New Job', () {
                Navigator.pop(context);
                // Navigate to new job screen
              }),
              _buildAddOptionItem(Icons.calendar_today, 'New Appointment', () {
                Navigator.pop(context);
                // Navigate to new appointment screen
              }),
              _buildAddOptionItem(Icons.receipt, 'New Invoice', () {
                Navigator.pop(context);
                // Navigate to new invoice screen
              }),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOptionItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTypography.fontSize10),
      onTap: onTap,
    );
  }
}
