import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/set_up_di.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Logs Viewer Screen - Shows all Talker logs for debugging
/// Client can share logs with you for remote troubleshooting
class LogsViewerScreen extends StatelessWidget {
  const LogsViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final talker = SetUpDI.getIt<Talker>();

    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 72.h),
            child: TalkerScreen(
              talker: talker,
              theme: TalkerScreenTheme(
                backgroundColor: AppColors.kBg,
                textColor: Colors.black,
              ),
            ),
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16.w,
                right: 16.w,
                bottom: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.kBg.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomNavButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CupertinoIcons.back,
                  ),
                  const Text(
                    'Debug Logs',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomNavButton(
                        onPressed: () => _shareLogs(talker),
                        icon: CupertinoIcons.share,
                      ),
                      CustomNavButton(
                        onPressed: () {
                          talker.cleanHistory();
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(content: Text('Logs cleared')),
                          );
                        },
                        icon: CupertinoIcons.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Share logs as text file - client can send this to you
  void _shareLogs(Talker talker) {
    final logs = talker.history
        .map((e) => '[${e.displayTime}] ${e.message}')
        .join('\n');

    if (logs.isEmpty) {
      return;
    }

    Share.share(logs, subject: 'RepairCMS Debug Logs - ${DateTime.now()}');
  }
}
