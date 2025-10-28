import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/widgets/job_details_screen.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
import 'package:repair_cms/core/constants/app_colors.dart';

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
                    color: job.jobStatus.isNotEmpty
                        ? (job.status.toLowerCase() == 'completed'
                              ? Colors.green
                              : job.status.toLowerCase() == 'in progress'
                              ? Colors.orange
                              : Colors.blue)
                        : Colors.grey,
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
                    const Text('Priority:', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(width: 4),
                    Icon(Icons.flag, color: _getPriorityColor(job), size: 15.h),
                    const SizedBox(width: 4),
                    Text(
                      _getPriorityText(job),
                      style: TextStyle(color: _getPriorityColor(job), fontSize: 12, fontWeight: FontWeight.w600),
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
                      Text(
                        'Job ID: ${job.jobNo}',
                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.dueDate} | ${_getWarrantyText(job)} | Location: ${job.customerDetails.shippingAddress.city}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.deviceId,
                        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'IMEI/SN: ${job.deviceData.imei ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      if (job.assignerName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Customer: ${job.assignerName}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                      if (job.total != '0') ...[
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${job.total}',
                          style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => JobDetailsScreen(jobId: job.id)));
                  },
                  child: const Icon(Icons.chevron_right, color: AppColors.fontMainColor, size: 24),
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
    final lastStatus = job.jobStatus.isNotEmpty ? job.jobStatus.last : null;
    if (lastStatus?.priority == 'High') {
      return Colors.red;
    } else if (lastStatus?.priority == 'Medium') {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _getPriorityText(Job job) {
    final lastStatus = job.jobStatus.isNotEmpty ? job.jobStatus.last : null;
    return lastStatus?.priority?.toString() ?? 'Standard';
  }

  String _getWarrantyText(Job job) {
    // You can customize this based on your warranty logic
    return job.services.isNotEmpty ? 'Warranty' : 'No Warranty';
  }
}
