import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:repair_cms/set_up_di.dart';
import 'package:share_plus/share_plus.dart';

/// Logs Viewer Screen - Shows all Talker logs for debugging
/// Client can share logs with you for remote troubleshooting
class LogsViewerScreen extends StatelessWidget {
  const LogsViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final talker = SetUpDI.getIt<Talker>();

    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.kBg,
        leading: CustomNavButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: CupertinoIcons.back,
        ),
        middle: const Text('Debug Logs'),
        trailing: Row(
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
                ).showSnackBar(const SnackBar(content: Text('Logs cleared')));
              },
              icon: CupertinoIcons.delete,
            ),
          ],
        ),
      ),
      body: TalkerScreen(
        talker: talker,
        theme: TalkerScreenTheme(
          backgroundColor: AppColors.kBg,
          textColor: Colors.black,
        ),
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
