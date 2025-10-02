import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  int _selectedTabIndex = 0;
  int _selectedBottomIndex = 0;
  final List<String> _tabTitles = ['Job Details', 'Device Details'];

  bool isJobComplete = false;
  bool returnDevice = true;

  String selectedPriority = 'Neutral';
  String selectedDueDate = '14. March 2025';
  String selectedAssignee = 'Susan Lemmes';

  @override
  void initState() {
    super.initState();
    // Initialize job complete status based on actual job status
    isJobComplete = widget.job.status.toLowerCase() == 'complete';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
        }

        if (state is JobStatusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job status updated successfully'), backgroundColor: Colors.green),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.job.customerName,
                style: GoogleFonts.roboto(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                'Auftrag-Nr: ${widget.job.jobNo}',
                style: GoogleFonts.roboto(color: Colors.grey.shade600, fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildCurrentScreen(),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedBottomIndex) {
      case 0:
        return _buildJobDetailsScreen();
      case 1:
        return _buildReceiptsScreen();
      case 2:
        return _buildStatusScreen();
      case 3:
        return _buildNotesScreen();
      case 4:
        return _buildMoreScreen();
      default:
        return _buildJobDetailsScreen();
    }
  }

  Widget _buildJobDetailsScreen() {
    return Column(
      children: [
        // Toggle Switches Section
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set Job Complete',
                    style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  CupertinoSwitch(
                    value: isJobComplete,
                    onChanged: (value) {
                      setState(() {
                        isJobComplete = value;
                      });
                      // Update job status in backend
                      if (value) {
                        context.read<JobCubit>().updateJobStatus(widget.job.id, 'complete', 'Job marked as complete');
                      }
                    },
                    activeTrackColor: Colors.grey.shade400,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Return device',
                    style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                  CupertinoSwitch(
                    value: returnDevice,
                    onChanged: (value) {
                      setState(() {
                        returnDevice = value;
                      });
                    },
                    activeTrackColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 8.h),

        // Tab Card (redesigned to match image)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildTabCard(),
        ),

        SizedBox(height: 16.h),

        // Content (Job Management etc)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Management Section (All dropdowns together)
                _buildInfoCard(
                  title: 'Job Management',
                  children: [
                    // Job Priority
                    Text(
                      'Job Priority',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    _buildDropdownField(
                      icon: Icons.flag_outlined,
                      value: _getCurrentPriority(),
                      items: ['High', 'Medium', 'Neutral'],
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Due Date
                    Text(
                      'Due Date',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    _buildDropdownField(
                      icon: Icons.calendar_today_outlined,
                      value: '',
                      items: [],
                      onChanged: (value) {
                        setState(() {
                          selectedDueDate = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Assignee
                    Text(
                      'Assignee',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // _buildDropdownField(
                    //   icon: Icons.person_outline,
                    //   value: '',
                    //   items: ['Susan Lemmes', 'John Doe', 'Jane Smith'],
                    //   onChanged: (value) {
                    //     setState(() {
                    //       selectedAssignee = value!;
                    //     });
                    //   },
                    //   hasAvatar: true,
                    // ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Customer Information
                _buildInfoCard(
                  title: 'Customer Information',
                  children: [
                    _buildInfoRow('Name', widget.job.customerName),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Email', widget.job.customerDetails.email),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Phone', widget.job.customerDetails.telephone),
                    SizedBox(height: 12.h),
                    _buildInfoSection('Address', widget.job.customerDetails.shippingAddress.formattedAddress),
                  ],
                ),

                SizedBox(height: 24.h),

                // Financial Information
                if (widget.job.total != '0')
                  _buildInfoCard(
                    title: 'Financial Information',
                    children: [
                      _buildInfoRow('Subtotal', '€${widget.job.subTotal}'),
                      SizedBox(height: 8.h),
                      _buildInfoRow('VAT', '€${widget.job.vat}'),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Discount', '€${widget.job.discount}'),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Total', '€${widget.job.total}'),
                    ],
                  ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods to get real data
  String _getCurrentPriority() {
    final lastStatus = widget.job.jobStatus.isNotEmpty ? widget.job.jobStatus.last : null;
    return lastStatus?.priority?.toString() ?? selectedPriority;
  }

  // String _getDueDate() {
  //   // You can calculate due date based on created date + standard turnaround
  //   final dueDate = widget.job.createdAt.add(const Duration(days: 7));
  //   return '${dueDate.day}. ${_getMonthName(dueDate.month)} ${dueDate.year}';
  // }

  String _getCurrentAssignee() {
    final lastStatus = widget.job.jobStatus.isNotEmpty ? widget.job.jobStatus.last : null;
    return lastStatus?.userName ?? selectedAssignee;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Rest of your existing methods remain the same, but updated with real data:
  Widget _buildTabCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Tabs row inside the card
          Row(
            children: _tabTitles.asMap().entries.map((entry) {
              final int index = entry.key;
              final String title = entry.value;
              final bool isSelected = _selectedTabIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(index == 0 ? 12.r : 0),
                        topRight: Radius.circular(index == _tabTitles.length - 1 ? 12.r : 0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.blue : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 3.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          // Content area with real data
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: _selectedTabIndex == 0 ? _jobDetailsCardContent() : _deviceDetailsCardContent(),
          ),
        ],
      ),
    );
  }

  Widget _jobDetailsCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardInfoRow('Physical location:', widget.job.physicalLocation ?? 'Not specified'),
        SizedBox(height: 12.h),
        _buildCardInfoRow('Defect type:', _getDefectType()),
        SizedBox(height: 12.h),
        _buildCardInfoSection('Problem Description:', _getProblemDescription()),
      ],
    );
  }

  Widget _deviceDetailsCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardInfoRow('Device:', widget.job.deviceInfo),
        SizedBox(height: 12.h),
        _buildCardInfoRow('IMEI/SN:', widget.job.deviceData.imei ?? 'N/A'),
        SizedBox(height: 12.h),
        if (widget.job.deviceData.color != null) _buildCardInfoRow('Color:', widget.job.deviceData.color!),
        if (widget.job.deviceData.color != null) SizedBox(height: 12.h),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Show Device Security',
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
              color: Colors.blue,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getDefectType() {
    if (widget.job.defect.isNotEmpty && widget.job.defect.first.defect.isNotEmpty) {
      return widget.job.defect.first.defect.first.value;
    }
    return 'Not specified';
  }

  String _getProblemDescription() {
    if (widget.job.defect.isNotEmpty) {
      return widget.job.defect.first.description ?? 'No description provided';
    }
    return 'No description provided';
  }

  // Updated receipts screen with real data
  Widget _buildReceiptsScreen() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Text(
            'Receipts & Documents',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              if (widget.job.total != '0')
                _buildReceiptItem(
                  'Invoice #${widget.job.jobNo}',
                  widget.job.formattedDate,
                  '€${widget.job.total}',
                  Icons.receipt_long,
                  Colors.blue,
                ),

              SizedBox(height: 12.h),

              _buildReceiptItem(
                'Quote #${widget.job.jobNo}-QT',
                widget.job.formattedDate,
                '€${widget.job.total}',
                Icons.request_quote,
                Colors.orange,
              ),

              SizedBox(height: 12.h),

              _buildReceiptItem('Diagnostic Report', widget.job.formattedDate, 'PDF', Icons.description, Colors.green),

              if (widget.job.signatureFilePath != null) ...[
                SizedBox(height: 12.h),
                _buildReceiptItem(
                  'Customer Authorization',
                  widget.job.formattedDate,
                  'Signed',
                  Icons.verified_user,
                  Colors.purple,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Updated status screen with real job status history
  Widget _buildStatusScreen() {
    final statusHistory = widget.job.jobStatus;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Text(
            'Job Status Timeline',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              ...statusHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final status = entry.value;
                final isCompleted = index < statusHistory.length - 1 || widget.job.status.toLowerCase() == 'complete';

                return _buildStatusItem(
                  status.title,
                  _formatTimestamp(status.createAtStatus),
                  status.notes.isNotEmpty ? status.notes : 'Status updated',
                  isCompleted,
                  _getStatusColor(status.colorCode),
                );
              }).toList(),

              // Add current status if not in history
              if (statusHistory.isEmpty)
                _buildStatusItem(
                  widget.job.status,
                  widget.job.formattedDate,
                  'Job created',
                  true,
                  widget.job.statusColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}. ${_getMonthName(date.month)} ${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String colorCode) {
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  // Updated notes screen with real internal notes
  Widget _buildNotesScreen() {
    final internalNotes = widget.job.defect.isNotEmpty ? widget.job.defect.first.internalNote : [];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Notes',
                style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              IconButton(
                onPressed: () {
                  _showAddNoteDialog(context);
                },
                icon: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              if (internalNotes.isNotEmpty)
                ...internalNotes
                    .map(
                      (note) =>
                          _buildNoteItem('Internal Note', note.text, note.userName, _formatTimestamp(note.createdAt)),
                    )
                    .toList(),

              if (internalNotes.isEmpty)
                _buildNoteItem('No notes yet', 'Add the first note for this job', 'System', widget.job.formattedDate),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(maxLines: 5, decoration: const InputDecoration(hintText: 'Enter your note...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Add note logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added successfully')));
            },
            child: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  // Keep all your existing UI helper methods (they're great!):
  Widget _buildCardInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF3A4A67)),
        ),
        SizedBox(width: 6.h),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.roboto(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  Widget _buildCardInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF3A4A67)),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptItem(String title, String date, String amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, String time, String description, bool isCompleted, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(color: isCompleted ? color : Colors.grey.shade300, shape: BoxShape.circle),
              child: isCompleted ? Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            Container(
              width: 2.w,
              height: 40.h,
              color: Colors.grey.shade300,
              margin: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.r),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  style: GoogleFonts.roboto(fontSize: 12.sp, color: color, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteItem(String title, String content, String author, String time) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Icon(Icons.more_vert, color: Colors.grey.shade400),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.black87, height: 1.4),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade500),
              SizedBox(width: 4.w),
              Text(
                author,
                style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
              SizedBox(width: 4.w),
              Text(
                time,
                style: GoogleFonts.roboto(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreScreen() {
    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.r),
          width: double.infinity,
          child: Text(
            'More Options',
            style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              _buildMoreOption(Icons.photo_camera, 'Take Photos', 'Capture device condition photos', Colors.blue),
              _buildMoreOption(Icons.share, 'Share Job', 'Send job details to customer or team', Colors.green),
              _buildMoreOption(Icons.print, 'Print Labels', 'Print job and device labels', Colors.orange),
              _buildMoreOption(Icons.history, 'Job History', 'View complete job timeline', Colors.purple),
              _buildMoreOption(Icons.attach_money, 'Update Pricing', 'Modify quotes and billing', Colors.teal),
              _buildMoreOption(Icons.person_add, 'Reassign Job', 'Change job assignee', Colors.indigo),
              _buildMoreOption(Icons.priority_high, 'Change Priority', 'Update job priority level', Colors.red),
              _buildMoreOption(Icons.settings, 'Job Settings', 'Configure job preferences', Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // Keep all your other existing methods (_buildMoreScreen, _buildMoreOption,
  // _buildInfoCard, _buildInfoRow, _buildInfoSection, _buildDropdownField,
  // _buildBottomNavBar, _buildNavItem) as they are...

  // [Include all the remaining methods from your original code exactly as they are]
  // _buildMoreScreen(), _buildMoreOption(), _buildInfoCard(), _buildInfoRow(),
  // _buildInfoSection(), _buildDropdownField(), _buildBottomNavBar(), _buildNavItem()

  // New single card that contains tabs and the content styled like the provided image

  Widget _buildMoreOption(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // Handle option tap
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title tapped')));
          },
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children, String? title}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...children]),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool hasAvatar = false,
  }) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (hasAvatar) ...[
                    CircleAvatar(
                      radius: 12.r,
                      backgroundColor: Colors.green,
                      child: Text(
                        item.split(' ').map((word) => word[0]).join(),
                        style: GoogleFonts.roboto(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ] else ...[
                    Icon(icon, color: Colors.blue, size: 20),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80.h,
      color: const Color(0xFF1E3A5F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.description_outlined, 'Job Details', 0),
          _buildNavItem(Icons.receipt_outlined, 'Receipt´s', 1),
          _buildNavItem(Icons.access_time, 'Status', 2),
          _buildNavItem(Icons.notes_outlined, 'Notes', 3),
          _buildNavItem(Icons.more_horiz, 'More', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade400, size: 24),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 10.sp,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
