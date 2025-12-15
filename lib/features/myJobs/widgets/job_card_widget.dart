import 'package:repair_cms/core/app_exports.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/features/myJobs/widgets/job_details_screen.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';

class JobCardWidget extends StatelessWidget {
  final Job job;

  const JobCardWidget({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Priority Row
          Padding(
            padding: EdgeInsets.only(right: 16.w, top: 16.w, bottom: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: job.jobStatus.isNotEmpty ? _getStatusColor(job) : Colors.grey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.w),
                      bottomRight: Radius.circular(30.w),
                    ),
                  ),
                  child: Text(
                    job.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Text('Priority:', style: AppTypography.fontSize16Normal.copyWith(color: AppColors.fontMainColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.flag, color: _getPriorityColor(job), size: 15.h),
                    const SizedBox(width: 4),
                    Text(
                      _getPriorityText(job),
                      style: AppTypography.fontSize16Normal.copyWith(
                        color: AppColors.fontSecondaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Job Details
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job ID label (600) and job number (500) with Roboto
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Job ID: ',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.fontMainColor,
                              ),
                            ),
                            TextSpan(
                              text: job.jobNo,
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.fontSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.dueDate} | ${_getWarrantyText(job)} | Location: ${job.customerDetails.shippingAddress.city}',
                        style: AppTypography.fontSize16Normal.copyWith(fontSize: 16.sp, color: AppColors.fontMainColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.deviceData.brand ?? 'Unknown',
                        style: AppTypography.fontSize16Normal.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fontMainColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'IMEI/SN: ${job.deviceData.imei ?? 'N/A'}',
                        style: AppTypography.fontSize16Normal.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.fontSecondaryColor,
                        ),
                      ),
                      // if (job.assignerName.isNotEmpty) ...[
                      //   const SizedBox(height: 8),
                      //   Text(
                      //     'Customer: ${job.assignerName}',
                      //     style: const TextStyle(color: Colors.black54, fontSize: 12),
                      //   ),
                      // ],
                      // if (job.total != '0') ...[
                      //   const SizedBox(height: 8),
                      //   Text(
                      //     'Total: ${job.total}',
                      //     style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600),
                      //   ),
                      //],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => JobDetailsScreen(jobId: job.id)));
                  },
                  child: Icon(Icons.chevron_right, color: AppColors.fontMainColor, size: 32.h),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Job job) {
    // You can customize this based on job priority from your data

    if (job.jobPriority!.toLowerCase() == 'high') {
      return Colors.red;
    } else if (job.jobPriority!.toLowerCase() == 'urgent') {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _getPriorityText(Job job) {
    return job.jobPriority ?? 'neutral';
  }

  String _getWarrantyText(Job job) {
    // You can customize this based on your warranty logic
    return job.services.isNotEmpty ? 'Warranty' : 'No Warranty';
  }

  Color _getStatusColor(Job job) {
    // Map various job.status values to colors
    final status = job.status.toLowerCase().trim();

    // Prefer using the latest jobStatus entry for some variants if needed
    // final lastStatus = job.jobStatus.isNotEmpty ? job.jobStatus.last.status?.toString()?.toLowerCase() : null;

    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in progress':
      case 'in_progress':
        return AppColors.warningColor;
      // 'ready_to_return' intentionally falls through to default mapping if not matched above
      case 'draft':
        return Colors.grey;
      case 'invoice_sent':
        return AppColors.fontMainColor;
      case 'quotation_sent':
        return Colors.purple;
      case 'booked':
        return Colors.lightBlue;
      case 'accepted_quotes':
        return Colors.blueAccent;
      case 'ready_to_return':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
