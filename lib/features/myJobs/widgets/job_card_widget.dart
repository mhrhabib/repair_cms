import 'package:figma_squircle/figma_squircle.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:repair_cms/features/myJobs/widgets/job_details_screen.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';

class JobCardWidget extends StatelessWidget {
  final Job job;

  const JobCardWidget({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(jobId: job.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16.r,
              cornerSmoothing: 1.0,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date, Status Badge, Priority
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date and Status
                Row(
                  children: [
                    Text(
                      job.dueDate != null
                          ? intl.DateFormat('dd.MM.yyyy').format(job.dueDate!)
                          : intl.DateFormat('dd.MM.yyyy').format(job.createdAt),
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _getStatusText(job),
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Priority Flag
                Row(
                  children: [
                    Text(
                      _getPriorityText(job),
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.flag,
                      color: _getPriorityColor(job),
                      size: 18.sp,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Job ID and Customer Name
            Row(
              children: [
                Expanded(
                  child: Text(
                    'JOB ID ${job.jobNo} | ${_getCustomerName()}',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF94A3B8),
                  size: 24.sp,
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Employee and Device Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Employee Avatar
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _getEmployeeInitial(),
                            style: GoogleFonts.roboto(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _getEmployeeName(),
                        style: GoogleFonts.roboto(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Text(
                    _getDeviceInfo(),
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCustomerName() {
    final firstName = job.customerDetails.firstName;
    final lastName = job.customerDetails.lastName;
    return '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Unknown Customer';
  }

  String _getEmployeeName() {
    return job.assignerName.trim().isNotEmpty
        ? job.assignerName.trim()
        : 'Unknown';
  }

  String _getEmployeeInitial() {
    final name = _getEmployeeName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _getDeviceInfo() {
    final brand = job.deviceData.brand ?? '';
    final model = job.deviceData.model ?? '';

    if (brand.isEmpty && model.isEmpty) {
      return 'Unknown Device';
    }

    return '$brand $model'.trim();
  }

  String _getStatusText(Job job) {
    final status = job.status.toLowerCase().trim();

    switch (status) {
      case 'booked':
        return 'Booked In';
      case 'in progress':
      case 'in_progress':
        return 'In Progress';
      case 'accepted_quotes':
        return 'Quote Accepted';
      case 'parts_not_available':
      case 'parts not available':
        return 'Parts not available';
      case 'ready_to_return':
        return 'Ready To Return';
      case 'quotation_sent':
        return 'Quote Rejected';
      case 'completed':
        return 'Completed';
      case 'draft':
        return 'Draft';
      default:
        return status;
    }
  }

  Color _getPriorityColor(Job job) {
    final priority = job.jobPriority?.toLowerCase() ?? 'neutral';

    switch (priority) {
      case 'urgent':
        return const Color(0xFFEF4444); // Red
      case 'high':
        return const Color(0xFFFF9800); // Orange
      case 'neutral':
      case 'normal':
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getPriorityText(Job job) {
    final priority = job.jobPriority?.toLowerCase() ?? 'neutral';

    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'high':
        return 'High';
      case 'neutral':
      case 'normal':
      default:
        return 'Neutral';
    }
  }
}
