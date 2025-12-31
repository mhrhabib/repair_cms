import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:solar_icons/solar_icons.dart';

class JobDetailsNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const JobDetailsNavbar({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      color: const Color(0xFF1E3A5F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(SolarIconsOutline.clipboardList, 'Job Details', 0),
          _buildNavItem(SolarIconsOutline.dialog2, 'Messages', 1),
          _buildNavItem(SolarIconsOutline.plugCircle, 'Status', 2),
          _buildNavItem(SolarIconsOutline.pen2, 'Notes', 3),
          _buildNavItem(SolarIconsOutline.cloudUpload, 'Files', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;

    // Determine border radius based on position
    BorderRadius borderRadius;
    if (index == 0) {
      // First item: rounded on top-left and bottom-left
      borderRadius = BorderRadius.only(bottomRight: Radius.circular(12.r));
    } else if (index == 4) {
      // Last item: rounded on top-right and bottom-right
      borderRadius = BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r));
    } else {
      // Middle items: no rounding
      borderRadius = BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r));
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        child: Container(
          height: 80.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A9EFF) : Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade400, size: 24),
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 10.sp,
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
