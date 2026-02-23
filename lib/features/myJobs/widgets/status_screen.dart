// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

class StatusScreen extends StatefulWidget {
  final SingleJobModel jobId;
  const StatusScreen({super.key, required this.jobId});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isInitialized = false;
  SingleJobModel? _cachedJobData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadJobDataIfNeeded();
        // Fetch status settings for the dropdown
        context.read<JobCubit>().getStatusSettings();
        _isInitialized = true;
      }
    });
  }

  void _loadJobDataIfNeeded() {
    final jobCubit = context.read<JobCubit>();
    final state = jobCubit.state;

    if (state is! JobDetailSuccess || state.job.data?.sId != widget.jobId.data?.sId) {
      jobCubit.getJobById(widget.jobId.data?.sId ?? '');
    }
  }

  void _showAddStatusBottomSheet() {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStatusBottomSheet(jobId: widget.jobId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color figmaBlue = const Color(0xFF007AFF);

    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        // Handle side effects like showing snackbars
        if (state is JobStatusUpdateSuccess) {
          SnackbarDemo(message: 'Status updated successfully').showCustomSnackbar(context);
        } else if (state is JobActionError) {
          SnackbarDemo(message: 'Failed to update status: ${state.message}').showCustomSnackbar(context);
        }
      },
      child: BlocBuilder<JobCubit, JobStates>(
        builder: (context, state) {
          // Cache job data when available
          if (state is JobDetailSuccess) {
            _cachedJobData = state.job;
          }
          
          // If we have cached job data, show it regardless of current state
          if (_cachedJobData != null) {
            return Scaffold(
              backgroundColor: AppColors.scaffoldBackgroundColor,
              appBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.back, color: figmaBlue, size: 28.r),
                      Text(
                        'Back',
                        style: TextStyle(color: figmaBlue, fontSize: 17.sp),
                      ),
                    ],
                  ),
                ),
                middle: Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showAddStatusBottomSheet,
                  child: Icon(CupertinoIcons.add_circled_solid, color: figmaBlue, size: 28.r),
                ),
              ),
              body: _buildStatusScreen(context, _cachedJobData!),
            );
          }
          
          // Show loading for initial states
          if (state is JobLoading || state is JobActionLoading || state is JobInitial) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } 
          
          // Show error
          if (state is JobError) {
            return Scaffold(body: Center(child: Text('Error: ${state.message}')));
          }
          
          // No data available
          return const Scaffold(body: Center(child: Text('No job data available')));
        },
      ),
    );
  }

  Widget _buildStatusScreen(BuildContext context, SingleJobModel job) {
    final statusHistory = job.data?.jobStatus ?? [];
    statusHistory.sort((a, b) => (b.createAtStatus ?? 0).compareTo(a.createAtStatus ?? 0));

    return Container(
      margin: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r), bottom: Radius.circular(16.r)),
      ),
      child: Column(
        children: [
          // Job Status Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Job Status',
                style: GoogleFonts.roboto(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3C3C43).withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          // Status History List
          Expanded(
            child: statusHistory.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: statusHistory.length,
                    itemBuilder: (context, index) {
                      final status = statusHistory[index];
                      final isLast = index == statusHistory.length - 1;
                      return _buildStatusListItem(
                        title: _formatStatusTitle(status.title ?? ''),
                        time: status.createAtStatus != null ? _formatTimestamp(status.createAtStatus!) : 'Unknown time',
                        userName: status.userName ?? 'System',
                        color: _getStatusColorForStatus(status.title ?? ''),
                        isLast: isLast,
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No status history available',
                      style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusListItem({
    required String title,
    required String time,
    required String userName,
    required Color color,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              // Color dot
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              // Dotted line connector (if not last item)
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    child: CustomPaint(painter: DottedLinePainter(color: Colors.grey.shade400)),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Status content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 16.h : 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3C3C43),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: GoogleFonts.roboto(fontSize: 15.sp, color: const Color(0xFF3C3C43).withValues(alpha: 0.6)),
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.roboto(fontSize: 15.sp, color: const Color(0xFF3C3C43).withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Add Status Bottom Sheet - FIXED VERSION
class AddStatusBottomSheet extends StatefulWidget {
  final SingleJobModel jobId;
  const AddStatusBottomSheet({super.key, required this.jobId});

  @override
  State<AddStatusBottomSheet> createState() => _AddStatusBottomSheetState();
}

class _AddStatusBottomSheetState extends State<AddStatusBottomSheet> {
  String? selectedStatus;
  String? selectedNotification = 'Yes';
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  // Update the _saveStatus method in AddStatusBottomSheet class
  void _saveStatus() {
    if (selectedStatus == null) {
      SnackbarDemo(message: 'Please select status').showCustomSnackbar(context);
      return;
    }

    final jobCubit = context.read<JobCubit>();
    final storage = GetStorage();

    // Get current user info from storage
    final userId = storage.read('userId');
    final userName = storage.read('fullName');
    final email = storage.read('email');

    if (userId == null || userName == null || email == null) {
      SnackbarDemo(message: 'User information not found').showCustomSnackbar(context);
      return;
    }

    // Call the cubit method - the BlocListener will handle the response
    jobCubit
        .addJobStatus(
          jobId: widget.jobId.data?.sId ?? '',
          status: selectedStatus!,
          userId: userId,
          userName: userName,
          email: email,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
          sendNotification: selectedNotification == 'Yes',
        )
        .then((_) {
          // Close the bottom sheet on successful API call initiation
          Navigator.pop(context);
          // Note: The success/error messages are now handled by BlocListener
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobCubit, JobStates>(
      builder: (context, state) {
        final isLoading = state is JobActionLoading;
        
        // Get dynamic statuses from state
        List<Map<String, dynamic>> availableStatuses = [];
        
        // Add hardcoded statuses first
        availableStatuses = [
          {'value': 'repair_in_progress', 'label': 'Repair in Progress', 'color': Colors.blue},
          {'value': 'quotation_accepted', 'label': 'Quotation Accepted', 'color': Colors.orange},
          {'value': 'rejected_quotes', 'label': 'Rejected Quotes', 'color': Colors.purple},
          {'value': 'ready_to_return', 'label': 'Ready to Return', 'color': Colors.green},
          {'value': 'parts_not_available', 'label': 'Parts Not Available', 'color': Colors.green},
          {'value': 'booked', 'label': 'Booked', 'color': Colors.red},
        ];
        
        // Add API statuses if loaded
        if (state is JobStatusSettingsLoaded) {
          final apiStatuses = state.statusSettings.status.map((statusSetting) {
            return {
              'value': statusSetting.statusName.toLowerCase().replaceAll(' ', '_'),
              'label': statusSetting.statusName,
              'color': _hexToColor(statusSetting.colorCode),
            };
          }).toList();
          availableStatuses.addAll(apiStatuses);
        }

        return Material(
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black87, size: 24.sp),
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Add Status',
                          style: GoogleFonts.roboto(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Content - Made scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.r),
                      child: AbsorbPointer(
                        absorbing: isLoading,
                        child: Opacity(
                          opacity: isLoading ? 0.6 : 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Select Status
                              Text(
                                'Select Status',
                                style: GoogleFonts.roboto(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedStatus,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    border: InputBorder.none,
                                  ),
                                  hint: Text('Select status...'),
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                                  items: availableStatuses.map((status) {
                                    return DropdownMenuItem<String>(
                                      value: status['value'],
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12.w,
                                            height: 12.h,
                                            margin: EdgeInsets.only(right: 12.w),
                                            decoration: BoxDecoration(color: status['color'], shape: BoxShape.circle),
                                          ),
                                          Text(
                                            status['label'],
                                            style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedStatus = value;
                                          });
                                        },
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Notification
                              Text(
                                'Notification',
                                style: GoogleFonts.roboto(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: DropdownButtonFormField<String>(
                                  initialValue: selectedNotification,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    border: InputBorder.none,
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                                  items: ['Yes', 'No'].map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedNotification = value;
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Notes
                              Text(
                                'Notes',
                                style: GoogleFonts.roboto(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: notesController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Add your notes...',
                                  hintStyle: GoogleFonts.roboto(color: Colors.grey.shade400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                  contentPadding: EdgeInsets.all(12.r),
                                ),
                              ),

                              // Add extra space at the bottom for the button
                              SizedBox(height: 80.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Fixed Save Button at bottom
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: SizedBox(
                      height: 48.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoading ? Colors.grey : Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                'Save',
                                style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper functions
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
    dayPrefix = '${date.day}.${date.month}.${date.year}';
  }

  String hour = date.hour.toString().padLeft(2, '0');
  String minute = date.minute.toString().padLeft(2, '0');
  return '$dayPrefix | $hour:$minute';
}

String _formatStatusTitle(String title) {
  return title
      .split('_')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ')
      .replaceAll('_', ' ');
}

Color _getStatusColorForStatus(String status) {
  // Map status values to colors
  final statusLower = status.toLowerCase();

  if (statusLower.contains('repair') || statusLower.contains('progress')) {
    return Colors.blue;
  } else if (statusLower.contains('quotation')) {
    return Colors.orange;
  } else if (statusLower.contains('invoice')) {
    return Colors.purple;
  } else if (statusLower.contains('ready') || statusLower.contains('return')) {
    return Colors.green;
  } else if (statusLower.contains('complete') || statusLower.contains('finished')) {
    return Colors.green;
  } else if (statusLower.contains('cancel')) {
    return Colors.red;
  } else if (statusLower.contains('archive')) {
    return Colors.grey;
  } else if (statusLower.contains('pending') || statusLower.contains('waiting')) {
    return Colors.amber;
  } else if (statusLower.contains('new') || statusLower.contains('created')) {
    return Colors.blue.shade300;
  }

  return Colors.blue; // Default color
}

Color _hexToColor(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor'; // Add alpha if not present
  }
  return Color(int.parse('0x$hexColor'));
}
