import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(icon: const Icon(Icons.share), tooltip: 'Share Logs', onPressed: () => _shareLogs(talker)),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
            onPressed: () {
              talker.cleanHistory();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs cleared')));
            },
          ),
        ],
      ),
      body: TalkerScreen(
        talker: talker,
        theme: const TalkerScreenTheme(backgroundColor: Colors.white, textColor: Colors.black),
      ),
    );
  }

  /// Share logs as text file - client can send this to you
  void _shareLogs(Talker talker) {
    final logs = talker.history.map((e) => '[${e.displayTime}] ${e.message}').join('\n');

    if (logs.isEmpty) {
      return;
    }

    Share.share(logs, subject: 'RepairCMS Debug Logs - ${DateTime.now()}');
  }
}
