import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:solar_icons/solar_icons.dart';
// Import the new screens
import './screens/a4_receipt_printer_screen.dart';
import './screens/thermal_printer_screen.dart';
import './screens/label_printer_screen.dart';

class PrinterSettingsScreen extends StatelessWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.kBg,
        leading: CustomNavButton(
          onPressed: () => Navigator.pop(context),
          icon: CupertinoIcons.back,
        ),
        middle: const Text(
          'Printer Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // A4 Receipt Printer
            _buildSettingsItem(
              iconsWidget: Icon(
                SolarIconsOutline.documentText,
                color: Colors.blue,
              ),
              title: 'A4 Receipt Printer',
              onTap: () {
                try {
                  debugPrint('🔄 [PrinterSettings] Navigating to A4 Printer');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const A4ReceiptPrinterScreen(),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    '❌ [PrinterSettings] Error navigating to A4 Printer: $e',
                  );
                }
              },
            ),

            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.deviderColor, width: 0.5),
                ),
              ),
            ),

            // Thermal Printer (80mm)
            _buildSettingsItem(
              iconsWidget: Image.asset(
                'assets/icon/Vector (Stroke).png',
                height: 24,
                width: 24,
              ),
              title: 'Thermal Printer (80mm)',
              onTap: () {
                try {
                  debugPrint(
                    '🔄 [PrinterSettings] Navigating to Thermal Printer',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ThermalPrinterScreen(),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    '❌ [PrinterSettings] Error navigating to Thermal Printer: $e',
                  );
                }
              },
            ),

            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.deviderColor, width: 0.5),
                ),
              ),
            ),

            // Label Printer
            _buildSettingsItem(
              iconsWidget: Image.asset(
                'assets/icon/label.png',
                height: 24,
                width: 24,
              ),
              title: 'Label Printer',
              onTap: () {
                try {
                  debugPrint(
                    '🔄 [PrinterSettings] Navigating to Label Printer',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LabelPrinterScreen(),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                    '❌ [PrinterSettings] Error navigating to Label Printer: $e',
                  );
                }
              },
            ),
            Container(
              height: 1,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * .78,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.deviderColor, width: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required Widget iconsWidget,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconsWidget,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.sfProText15.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.fontMainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.fontMainColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
