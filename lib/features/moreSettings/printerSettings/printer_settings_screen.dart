import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
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
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Printer Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // A4 Receipt Printer
            _buildSettingsItem(
              icon: SolarIconsOutline.document1,
              iconColor: Colors.blue,
              title: 'A4 Receipt Printer',
              onTap: () {
                try {
                  debugPrint('🔄 [PrinterSettings] Navigating to A4 Printer');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const A4PrinterScreen(),
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
              icon: SolarIconsOutline.documentMedicine,
              iconColor: Colors.blue,
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
              icon: SolarIconsOutline.document,
              iconColor: Colors.blue,
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
    required IconData icon,
    required Color iconColor,
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
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
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
