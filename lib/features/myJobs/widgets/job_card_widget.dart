import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/job_details_screen.dart';

Widget jobCardWidget({
  required String status,
  required Color statusColor,
  required String priority,
  required Color priorityColor,
  required String jobId,
  required String date,
  required String warranty,
  required String location,
  required String deviceName,
  required String imei,
  BuildContext? context,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      // borderRadius: BorderRadius.circular(12),
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
                  color: statusColor,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(30.w), bottomRight: Radius.circular(30.w)),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: [
                  const Text('Priority:', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(width: 4),
                  Icon(Icons.flag, color: priorityColor, size: 15.h),
                  const SizedBox(width: 4),
                  Text(
                    priority,
                    style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.w600),
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
                      'Job ID: $jobId',
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date | $warranty | Location: $location',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deviceName,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(imei, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context!).push(MaterialPageRoute(builder: (context) => JobDetailsScreen()));
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
