import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<JobCubit, JobStates>(
          builder: (context, state) {
            if (state is JobDetailSuccess) {
              return _buildStatusScreen(state.job);
            } else if (state is JobLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JobError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No job data available'));
          },
        ),
      ),
    );
  }
}

// Updated status screen with real job status history
Widget _buildStatusScreen(SingleJobModel job) {
  // Get status history from job data
  final statusHistory = job.data?.jobStatus ?? [];

  // Sort status history by timestamp in descending order (newest first)
  statusHistory.sort((a, b) => (b.createAtStatus ?? 0).compareTo(a.createAtStatus ?? 0));

  return Column(
    children: [
      // Header
      Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.r),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Status Timeline',
              style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            Text(
              'Job No: ${job.data?.jobNo ?? 'N/A'}',
              style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),

      SizedBox(height: 8.h),

      // Current Status Card
      if (job.data?.status != null)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: _getStatusColorForCurrentStatus(job.data!.status!),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatStatusTitle(job.data!.status!),
                        style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      SizedBox(height: 16.h),

      // Status History
      Expanded(
        child: statusHistory.isNotEmpty
            ? ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  Text(
                    'Status History',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ...statusHistory.asMap().entries.map((entry) {
                    final status = entry.value;
                    final isLast = entry.key == statusHistory.length - 1;

                    return _buildStatusItem(
                      title: _formatStatusTitle(status.title ?? ''),
                      time: status.createAtStatus != null ? _formatTimestamp(status.createAtStatus!) : 'Unknown time',
                      description: status.notes?.isNotEmpty == true
                          ? status.notes!
                          : 'Status updated to ${_formatStatusTitle(status.title ?? '')}',
                      userName: status.userName ?? 'System',
                      color: _getStatusColor(status.colorCode ?? '#008444'),
                      isLast: isLast,
                    );
                  }).toList(),
                ],
              )
            : Center(
                child: Text(
                  'No status history available',
                  style: GoogleFonts.roboto(fontSize: 16.sp, color: Colors.grey.shade600),
                ),
              ),
      ),
    ],
  );
}

Widget _buildStatusItem({
  required String title,
  required String time,
  required String description,
  required String userName,
  required Color color,
  bool isLast = false,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 16.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 16.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
            ),
            if (!isLast) ...[SizedBox(height: 4.h), Container(width: 2.w, height: 40.h, color: Colors.grey.shade300)],
          ],
        ),

        SizedBox(width: 16.w),

        // Status content
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        time,
                        style: GoogleFonts.roboto(fontSize: 10.sp, color: color, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                if (description.isNotEmpty) ...[
                  Text(
                    description,
                    style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade700, height: 1.4),
                  ),
                  SizedBox(height: 8.h),
                ],

                Text(
                  'By: $userName',
                  style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatTimestamp(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final dateDay = DateTime(date.year, date.month, date.day);

  String dayPrefix;
  if (dateDay == today) {
    dayPrefix = 'Today';
  } else if (dateDay == yesterday) {
    dayPrefix = 'Yesterday';
  } else {
    dayPrefix = '${date.day}. ${_getMonthName(date.month)} ${date.year}';
  }

  return '$dayPrefix - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

String _getMonthName(int month) {
  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return monthNames[month - 1];
}

String _formatStatusTitle(String title) {
  // Convert snake_case or kebab-case to Title Case
  return title
      .split('_')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ')
      .replaceAll('_', ' ');
}

Color _getStatusColor(String colorCode) {
  try {
    return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
  } catch (e) {
    return Colors.blue;
  }
}

Color _getStatusColorForCurrentStatus(String status) {
  // Map status to colors
  final statusColors = {
    'quotation_sent': Colors.orange,
    'invoice_sent': Colors.purple,
    'in_progress': Colors.blue,
    'ready_to_return': Colors.green,
    'complete': Colors.green,
    'archive': Colors.grey,
    'cancelled': Colors.red,
  };

  return statusColors[status.toLowerCase()] ?? Colors.blue;
}
