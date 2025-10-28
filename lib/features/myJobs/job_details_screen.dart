// import 'package:flutter/cupertino.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:repair_cms/core/app_exports.dart';
// import 'package:repair_cms/core/helpers/snakbar_demo.dart';
// import 'package:repair_cms/core/helpers/storage.dart';
// import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
// import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
// import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
// import 'package:repair_cms/features/myJobs/widgets/files_screen.dart';
// import 'package:repair_cms/features/myJobs/widgets/notes_screen.dart';
// import 'package:repair_cms/features/myJobs/widgets/receipt_screen.dart';
// import 'package:repair_cms/features/myJobs/widgets/status_screen.dart';

// class JobDetailsScreen extends StatefulWidget {
//   final String jobId;
//   const JobDetailsScreen({super.key, required this.jobId});

//   @override
//   State<JobDetailsScreen> createState() => _JobDetailsScreenState();
// }

// class _JobDetailsScreenState extends State<JobDetailsScreen> {
//   int _selectedBottomIndex = 0;
//   SingleJobModel? _currentJob;

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       debugPrint('Initialized Job Details Screen for Job ID: ${widget.jobId}');
//       context.read<JobCubit>().getJobById(widget.jobId);
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('Job Details Screen for Job ID: ${widget.jobId}');
//     return BlocListener<JobCubit, JobStates>(
//       listener: (context, state) {
//         if (state is JobError) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
//         }

//         if (state is JobStatusUpdated) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Job status updated successfully'), backgroundColor: Colors.green),
//           );
//         }
//         if (state is JobDetailSuccess) {
//           debugPrint('✅ Job Loaded: ${state.job.data!.sId}');
//           setState(() {
//             _currentJob = state.job;
//           });
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.scaffoldBackgroundColor,
//         body: BlocBuilder<JobCubit, JobStates>(
//           builder: (context, state) {
//             if (state is JobLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is JobDetailSuccess) {
//               return _buildCurrentScreen(state.job);
//             } else if (state is JobError) {
//               return Center(child: Text('Error: ${state.message}'));
//             }
//             // Fallback to the current job (either initial or updated)
//             return Center(child: Text('Eroor'));
//           },
//         ),
//         bottomNavigationBar: _buildBottomNavBar(),
//       ),
//     );
//   }

//   Widget _buildCurrentScreen(SingleJobModel job) {
//     debugPrint('Building current screen for Job ID: ${job.data!.sId}');
//     switch (_selectedBottomIndex) {
//       case 0:
//         return JobDetails(job: job);
//       case 1:
//         return ReceiptScreen(job: job);
//       case 2:
//         return StatusScreen(job: job);
//       case 3:
//         return NotesScreen(job: job);
//       case 4:
//         return FilesScreen();
//       default:
//         return JobDetails(job: job);
//     }
//   }

//   Widget _buildBottomNavBar() {
//     return Container(
//       height: 80.h,
//       color: const Color(0xFF1E3A5F),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildNavItem(Icons.description_outlined, 'Job Details', 0),
//           _buildNavItem(Icons.receipt_outlined, 'Receipt´s', 1),
//           _buildNavItem(Icons.access_time, 'Status', 2),
//           _buildNavItem(Icons.notes_outlined, 'Notes', 3),
//           _buildNavItem(Icons.more_horiz, 'Files', 4),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, int index) {
//     bool isSelected = _selectedBottomIndex == index;

//     // Determine border radius based on position
//     BorderRadius borderRadius;
//     if (index == 0) {
//       // First item: rounded on top-left and bottom-left
//       borderRadius = BorderRadius.only(bottomRight: Radius.circular(12.r));
//     } else if (index == 4) {
//       // Last item: rounded on top-right and bottom-right
//       borderRadius = BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r));
//     } else {
//       // Middle items: no rounding
//       borderRadius = BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r));
//     }

//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedBottomIndex = index;
//           });
//         },
//         child: Container(
//           height: 80.h,
//           margin: EdgeInsets.only(bottom: 12.h),
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFF4A9EFF) : Colors.transparent,
//             borderRadius: borderRadius,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade400, size: 24),
//               SizedBox(height: 4.h),
//               Text(
//                 label,
//                 style: GoogleFonts.roboto(
//                   fontSize: 10.sp,
//                   color: isSelected ? Colors.white : Colors.grey.shade400,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class JobDetails extends StatefulWidget {
//   const JobDetails({super.key, required this.job});

//   final SingleJobModel job;

//   @override
//   State<JobDetails> createState() => _JobDetailsState();
// }

// class _JobDetailsState extends State<JobDetails> {
//   final List<String> _tabTitles = ['Job Details', 'Device Details'];
//   int _selectedTabIndex = 0;

//   bool isJobComplete = false;
//   bool returnDevice = true;

//   String selectedPriority = 'Neutral';
//   String selectedDueDate = '14. March 2025';
//   String selectedAssignee = 'Susan Lemmes';

//   @override
//   void initState() {
//     super.initState();
//     // Initialize job complete status based on actual job status
//     isJobComplete = widget.job.status.toLowerCase() == 'complete';
//     print('Job ID in JobDetails: ${widget.job.id}');
//     print('Job Complete Status: $isJobComplete');
//     print('Job Status: ${widget.job.status}');
//   }

//   @override
//   void didUpdateWidget(JobDetails oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Update when job prop changes
//     if (oldWidget.job.id != widget.job.id) {
//       setState(() {
//         isJobComplete = widget.job.status.toLowerCase() == 'complete';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('Building JobDetails with Job ID: ${widget.job.id}');

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               widget.job.assignerName,
//               style: GoogleFonts.roboto(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600),
//             ),
//             Text(
//               'Auftrag-Nr: ${widget.job.jobNo}',
//               style: GoogleFonts.roboto(color: Colors.grey.shade600, fontSize: 12.sp, fontWeight: FontWeight.w400),
//             ),
//           ],
//         ),
//         centerTitle: true,
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: Container(
//                   width: 8.w,
//                   height: 8.h,
//                   decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: _buildJobDetailsScreen(widget.job),
//     );
//   }

//   Widget _buildJobDetailsScreen(Job job) {
//     print('Building JobDetailsScreen for Job ID: ${job.id}');
//     return Column(
//       children: [
//         // Toggle Switches Section
//         Container(
//           color: Colors.white,
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Set Job Complete',
//                     style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
//                   ),
//                   CupertinoSwitch(
//                     value: isJobComplete,
//                     onChanged: (value) {
//                       setState(() {
//                         isJobComplete = value;
//                         SnackbarDemo().showCustomSnackbar(context);
//                       });

//                       // Update job status in backend
//                       if (value) {
//                         context.read<JobCubit>().updateJobStatus(job.id, 'complete', 'Job marked as complete');
//                       }
//                     },
//                     activeTrackColor: Colors.grey.shade400,
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Return device',
//                     style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
//                   ),
//                   CupertinoSwitch(
//                     value: returnDevice,
//                     onChanged: (value) {
//                       setState(() {
//                         returnDevice = value;
//                       });
//                     },
//                     activeTrackColor: Colors.blue,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         SizedBox(height: 8.h),

//         // Tab Card (redesigned to match image)
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           child: _buildTabCard(job),
//         ),

//         SizedBox(height: 16.h),

//         // Content (Job Management etc)
//         Expanded(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Job Management Section (All dropdowns together)
//                 _buildInfoCard(
//                   title: 'Job Management',
//                   children: [
//                     // Job Priority
//                     Text(
//                       'Job Priority',
//                       style: GoogleFonts.roboto(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),

//                     _buildDropdownField(
//                       icon: Icons.flag_outlined,
//                       value: selectedPriority,
//                       items: ['Neutral', 'High', 'Urgent'],
//                       onChanged: (value) {
//                         debugPrint('Selected Priority for Job ${job.id}: $value');
//                         setState(() {
//                           selectedPriority = value!;
//                           // context.read<JobCubit>().updateJobPriority(job.id, selectedPriority);
//                         });
//                       },
//                     ),
//                     SizedBox(height: 20.h),

//                     // Due Date
//                     Text(
//                       'Due Date',
//                       style: GoogleFonts.roboto(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),

//                     _buildDropdownField(
//                       icon: Icons.calendar_today_outlined,
//                       value: selectedDueDate,
//                       items: ['14. March 2025', '15. March 2025', '16. March 2025'],
//                       onChanged: (value) {
//                         setState(() {
//                           selectedDueDate = value!;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 20.h),

//                     // Assignee
//                     Text(
//                       'Assignee',
//                       style: GoogleFonts.roboto(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     _buildDropdownField(
//                       icon: Icons.person_outline,
//                       value: selectedAssignee,
//                       items: ['Susan Lemmes', 'John Doe', 'Mike Johnson'],
//                       onChanged: (value) {
//                         setState(() {
//                           selectedAssignee = value!;
//                         });
//                       },
//                       hasAvatar: true,
//                     ),
//                   ],
//                 ),

//                 // Customer Information
//                 SizedBox(height: 16.h),
//                 _buildCustomerInfoCard(job),

//                 // Financial Information
//                 SizedBox(height: 16.h),
//                 _buildFinancialInfoCard(job),

//                 SizedBox(height: 24.h),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper methods to get real data
//   String _getCurrentPriority() {
//     final lastStatus = widget.job.jobStatus.isNotEmpty ? widget.job.jobStatus.last : null;
//     return lastStatus?.priority?.toString() ?? selectedPriority;
//   }

//   Widget _jobDetailsCardContent(Job job) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildCardInfoRow('Physical location:', job.physicalLocation ?? 'Not specified'),
//         SizedBox(height: 12.h),
//         _buildCardInfoRow('Defect type:', _getDefectType(job)),
//         SizedBox(height: 12.h),
//         _buildCardInfoSection('Problem Description:', _getProblemDescription(job)),
//       ],
//     );
//   }

//   String _getDefectType(Job job) {
//     if (job.defect.isNotEmpty && job.defect.first.defect.isNotEmpty) {
//       return job.defect.first.defect.first.value;
//     }
//     return 'Not specified';
//   }

//   Widget _deviceDetailsCardContent(Job job) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildCardInfoRow('Device:', job.deviceData.category ?? 'N/A'),
//         SizedBox(height: 12.h),
//         _buildCardInfoRow('IMEI/SN:', job.deviceData.imei ?? 'N/A'),
//         SizedBox(height: 12.h),
//         if (job.deviceData.model != null) _buildCardInfoRow('Model:', job.deviceData.model!),
//         if (job.deviceData.brand != null) _buildCardInfoRow('Brand:', job.deviceData.brand!),
//         SizedBox(height: 12.h),
//         Align(
//           alignment: Alignment.center,
//           child: Text(
//             'Show Device Security',
//             style: TextStyle(
//               decoration: TextDecoration.underline,
//               decorationColor: Colors.blue,
//               color: Colors.blue,
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _getProblemDescription(Job job) {
//     if (job.defect.isNotEmpty) {
//       return job.defect.first.description ?? 'No description provided';
//     }
//     return 'No description provided';
//   }

//   Widget _buildCustomerInfoCard(Job job) {
//     return _buildInfoCard(
//       title: 'Customer Information',
//       children: [
//         _buildInfoRow('Name', '${job.customerDetails.firstName} ${job.customerDetails.lastName}'),
//         SizedBox(height: 12.h),
//         _buildInfoRow('Email', job.customerDetails.email),
//         SizedBox(height: 12.h),
//         _buildInfoRow('Phone', '${job.customerDetails.telephonePrefix} ${job.customerDetails.telephone}'),
//         SizedBox(height: 12.h),
//         _buildInfoSection('Address', _getCustomerAddress(job)),
//       ],
//     );
//   }

//   Widget _buildFinancialInfoCard(Job job) {
//     return _buildInfoCard(
//       title: 'Financial Information',
//       children: [
//         _buildInfoRow('Subtotal', '\$${job.subTotal.toStringAsFixed(2)}'),
//         SizedBox(height: 8.h),
//         _buildInfoRow('VAT', '\$${job.vat.toStringAsFixed(2)}'),
//         SizedBox(height: 8.h),
//         _buildInfoRow('Discount', '\$${job.discount.toStringAsFixed(2)}'),
//         SizedBox(height: 8.h),
//         _buildInfoRow('Total', '\$${job.total.toStringAsFixed(2)}', isTotal: true),
//       ],
//     );
//   }

//   String _getCustomerAddress(Job job) {
//     final address = job.customerDetails.shippingAddress;
//     return '${address.street} ${address.id}, ${address.zip} ${address.city}, ${address.country}';
//   }

//   // Keep all your existing UI helper methods:
//   Widget _buildCardInfoRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF3A4A67)),
//         ),
//         SizedBox(width: 6.h),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.roboto(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCardInfoSection(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF3A4A67)),
//         ),
//         SizedBox(height: 6.h),
//         Text(
//           value,
//           style: GoogleFonts.roboto(
//             fontSize: 15.sp,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey.shade700,
//             height: 1.25,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoCard({required List<Widget> children, String? title}) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (title != null) ...[
//             Text(
//               title,
//               style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
//             ),
//             SizedBox(height: 12.h),
//           ],
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
//         ),
//         Text(
//           value,
//           style: GoogleFonts.roboto(
//             fontSize: 16.sp,
//             fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
//             color: isTotal ? Colors.green : Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoSection(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           value,
//           style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Colors.black87),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownField({
//     required IconData icon,
//     required String value,
//     required List<String> items,
//     required void Function(String?) onChanged,
//     bool hasAvatar = false,
//   }) {
//     return Container(
//       height: 40.h,
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.blue, width: 1.5),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value.isNotEmpty ? value : null,
//           onChanged: onChanged,
//           icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
//           isExpanded: true,
//           items: items.map((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Row(
//                 children: [
//                   if (hasAvatar) ...[
//                     CircleAvatar(
//                       radius: 12.r,
//                       backgroundColor: Colors.green,
//                       child: Text(
//                         item.split(' ').map((word) => word[0]).join(),
//                         style: GoogleFonts.roboto(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(width: 8.w),
//                   ] else ...[
//                     Icon(icon, color: Colors.blue, size: 20),
//                     SizedBox(width: 8.w),
//                   ],
//                   Expanded(
//                     child: Text(
//                       item,
//                       style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabCard(Job job) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         children: [
//           // Tabs row inside the card
//           Row(
//             children: _tabTitles.asMap().entries.map((entry) {
//               final int index = entry.key;
//               final String title = entry.value;
//               final bool isSelected = _selectedTabIndex == index;

//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedTabIndex = index;
//                     });
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 12.h),
//                     decoration: BoxDecoration(
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(index == 0 ? 12.r : 0),
//                         topRight: Radius.circular(index == _tabTitles.length - 1 ? 12.r : 0),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           title,
//                           style: GoogleFonts.roboto(
//                             fontSize: 14.sp,
//                             fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
//                             color: isSelected ? Colors.blue : Colors.grey.shade600,
//                           ),
//                         ),
//                         SizedBox(height: 8.h),
//                         Container(
//                           height: 3.h,
//                           width: 60.w,
//                           decoration: BoxDecoration(
//                             color: isSelected ? Colors.blue : Colors.transparent,
//                             borderRadius: BorderRadius.circular(4.r),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),

//           Divider(height: 1, color: Colors.grey.shade300),

//           // Content area with real data
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//             child: _selectedTabIndex == 0 ? _jobDetailsCardContent(job) : _deviceDetailsCardContent(job),
//           ),
//         ],
//       ),
//     );
//   }
// }
