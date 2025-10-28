// import 'package:flutter/cupertino.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:repair_cms/core/app_exports.dart';
// import 'package:repair_cms/features/myJobs/models/job_list_response.dart';

// class StatusScreen extends StatefulWidget {
//   const StatusScreen({super.key, });

//   @override
//   State<StatusScreen> createState() => _StatusScreenState();
// }

// class _StatusScreenState extends State<StatusScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return _buildStatusScreen();
//   }
// }

// // Updated status screen with real job status history
// Widget _buildStatusScreen(Job job) {
//   final statusHistory = job.jobStatus;

//   return Column(
//     children: [
//       Container(
//         color: Colors.white,
//         padding: EdgeInsets.all(16.r),
//         width: double.infinity,
//         child: Text(
//           'Job Status Timeline',
//           style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
//         ),
//       ),

//       Expanded(
//         child: ListView(
//           padding: EdgeInsets.all(16.r),
//           children: [
//             ...statusHistory.asMap().entries.map((entry) {
//               final index = entry.key;
//               final status = entry.value;
//               final isCompleted = index < statusHistory.length - 1 || job.status.toLowerCase() == 'complete';

//               return _buildStatusItem(
//                 status.title,
//                 _formatTimestamp(status.createAtStatus),
//                 status.notes.isNotEmpty ? status.notes : 'Status updated',
//                 isCompleted,
//                 _getStatusColor(status.colorCode),
//               );
//             }).toList(),

//             // Add current status if not in history
//             if (statusHistory.isEmpty)
//               _buildStatusItem(job.status, job.dueDate!.toString(), 'Job created', true, Colors.amberAccent),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildStatusItem(String title, String time, String description, bool isCompleted, Color color) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Column(
//         children: [
//           Container(
//             width: 20.w,
//             height: 20.h,
//             decoration: BoxDecoration(color: isCompleted ? color : Colors.grey.shade300, shape: BoxShape.circle),
//             child: isCompleted ? Icon(Icons.check, color: Colors.white, size: 14) : null,
//           ),
//           Container(
//             width: 2.w,
//             height: 40.h,
//             color: Colors.grey.shade300,
//             margin: EdgeInsets.symmetric(vertical: 8.h),
//           ),
//         ],
//       ),
//       SizedBox(width: 16.w),
//       Expanded(
//         child: Container(
//           padding: EdgeInsets.all(16.r),
//           margin: EdgeInsets.only(bottom: 8.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.r),
//             boxShadow: [
//               BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 time,
//                 style: GoogleFonts.roboto(fontSize: 12.sp, color: color, fontWeight: FontWeight.w500),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 description,
//                 style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
// }

// String _formatTimestamp(int timestamp) {
//   final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//   return '${date.day}. ${_getMonthName(date.month)} ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
// }

// String _getMonthName(int month) {
//   const monthNames = [
//     'January',
//     'February',
//     'March',
//     'April',
//     'May',
//     'June',
//     'July',
//     'August',
//     'September',
//     'October',
//     'November',
//     'December',
//   ];
//   return monthNames[month - 1];
// }

// Color _getStatusColor(String colorCode) {
//   try {
//     return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
//   } catch (e) {
//     return Colors.blue;
//   }
// }
