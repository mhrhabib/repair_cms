import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/job_details_navbar_screen.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/myJobs/widgets/files_screen.dart';
import 'package:repair_cms/features/myJobs/widgets/notes_screen.dart';
import 'package:repair_cms/features/myJobs/widgets/receipt_screen.dart';
import 'package:repair_cms/features/myJobs/widgets/status_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Initialized Job Details Screen for Job ID: ${widget.jobId}');
      context.read<JobCubit>().getJobById(widget.jobId);
    });
    super.initState();
  }

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Job Details Screen for Job ID: ${widget.jobId}');
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
        if (state is JobDetailSuccess) {
          debugPrint('✅ Job Loaded: ${state.job.data!.sId}');
          setState(() {});
        }
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          context.read<JobCubit>().getJobs();
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundColor,
          body: BlocBuilder<JobCubit, JobStates>(
            builder: (context, state) {
              if (state is JobLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is JobDetailSuccess) {
                return _buildCurrentScreen(state.job);
              } else if (state is JobError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              // Fallback to the current job (either initial or updated)
              return Center(child: Text('Job error: Unable to load job details. Please try again later.'));
            },
          ),
          bottomNavigationBar: JobDetailsNavbar(
            selectedIndex: _selectedBottomIndex,
            onItemSelected: _onNavItemSelected,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(SingleJobModel job) {
    debugPrint('Building current screen for Job ID: ${job.data!.sId}');
    switch (_selectedBottomIndex) {
      case 0:
        return JobDetailsContent(job: job);
      case 1:
        return ReceiptScreen(job: job);
      case 2:
        return StatusScreen();
      case 3:
        return NotesScreen(job: job);
      case 4:
        return FilesScreen();
      default:
        return JobDetailsContent(job: job);
    }
  }
}

class JobDetailsContent extends StatefulWidget {
  const JobDetailsContent({super.key, required this.job});

  final SingleJobModel job;

  @override
  State<JobDetailsContent> createState() => _JobDetailsContentState();
}

class _JobDetailsContentState extends State<JobDetailsContent> {
  final List<String> _tabTitles = ['Job Details', 'Device Details'];
  int _selectedTabIndex = 0;

  bool isJobComplete = false;
  bool returnDevice = false;

  String selectedPriority = 'Neutral';
  String selectedDueDate = '14. March 2025';
  String selectedAssignee = 'Susan Lemmes';

  @override
  void initState() {
    super.initState();
    // Initialize job complete status based on actual job status
    isJobComplete = widget.job.data!.isJobCompleted != null && widget.job.data!.isJobCompleted! == true;
    print('Job ID in JobDetails: ${widget.job.data!.sId}');
    print('Job Complete Status: $isJobComplete');
    print('Job Status: ${widget.job.data!.status}');
    print('Job complete Status: ${widget.job.data!.isJobCompleted}');
  }

  @override
  void didUpdateWidget(JobDetailsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when job prop changes
    if (oldWidget.job.data!.sId != widget.job.data!.sId) {
      setState(() {
        isJobComplete = widget.job.data!.isJobCompleted! == true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building JobDetails with Job ID: ${widget.job.data!.sId}');

    return Scaffold(
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
              widget.job.data!.contact!.isEmpty
                  ? 'Job Details'
                  : widget.job.data!.contact![0].firstName ?? 'Job Details',
              style: GoogleFonts.roboto(color: Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            Text(
              'Auftrag-Nr: ${widget.job.data!.jobNo}',
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
      body: _buildJobDetailsScreen(widget.job),
    );
  }

  Widget _buildJobDetailsScreen(SingleJobModel job) {
    print('Building JobDetailsScreen for Job ID: ${job.data!.sId}');
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
                        SnackbarDemo().showCustomSnackbar(context);
                      });

                      // Update job status in backend

                      context.read<JobCubit>().updateCompleteJobStatus(
                        job.data!.sId!,
                        'complete',
                        'Job marked as complete',
                        value,
                      );
                    },
                    activeTrackColor: Colors.blue,
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

                      context.read<JobCubit>().updateReturnJobStatus(
                        job.data!.sId!,
                        'complete',
                        'Job marked as return',
                        value,
                      );
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
          child: _buildTabCard(job),
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
                      value: selectedPriority,
                      items: ['Neutral', 'High', 'Urgent'],
                      onChanged: (value) {
                        debugPrint('Selected Priority for Job ${job.data!.sId}: $value');
                        setState(() {
                          selectedPriority = value!;
                          // context.read<JobCubit>().updateJobPriority(job.id, selectedPriority);
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
                      value: selectedDueDate,
                      items: ['14. March 2025', '15. March 2025', '16. March 2025'],
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
                    _buildDropdownField(
                      icon: Icons.person_outline,
                      value: selectedAssignee,
                      items: ['Susan Lemmes', 'John Doe', 'Mike Johnson'],
                      onChanged: (value) {
                        setState(() {
                          selectedAssignee = value!;
                        });
                      },
                      hasAvatar: true,
                    ),
                  ],
                ),

                // Customer Information
                SizedBox(height: 16.h),
                _buildCustomerInfoCard(job),

                // Financial Information
                SizedBox(height: 16.h),
                _buildFinancialInfoCard(job),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Keep all your existing UI helper methods (they remain the same):
  Widget _jobDetailsCardContent(SingleJobModel job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardInfoRow('Physical location:', job.data!.physicalLocation ?? 'Not specified'),
        SizedBox(height: 12.h),
        _buildCardInfoRow('Defect type:', _getDefectType(job)),
        SizedBox(height: 12.h),
        _buildCardInfoSection('Problem Description:', _getProblemDescription(job)),
      ],
    );
  }

  String _getDefectType(SingleJobModel job) {
    if (job.data!.defect!.isNotEmpty && job.data!.defect!.first.defect!.isNotEmpty) {
      return job.data!.defect!.first.defect!.first.value!;
    }
    return 'Not specified';
  }

  Widget _deviceDetailsCardContent(SingleJobModel job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardInfoRow('Device:', job.data!.deviceData!.type ?? 'N/A'),
        SizedBox(height: 12.h),
        _buildCardInfoRow('IMEI/SN:', job.data!.deviceData!.serialNo ?? 'N/A'),
        SizedBox(height: 12.h),
        if (job.data!.deviceData!.model != null) _buildCardInfoRow('Model:', job.data!.deviceData!.model!),
        if (job.data!.deviceData!.brand != null) _buildCardInfoRow('Brand:', job.data!.deviceData!.brand!),
        SizedBox(height: 12.h),
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

  String _getProblemDescription(SingleJobModel job) {
    if (job.data!.defect!.isNotEmpty) {
      return job.data!.defect!.first.description ?? 'No description provided';
    }
    return 'No description provided';
  }

  Widget _buildCustomerInfoCard(SingleJobModel job) {
    return _buildInfoCard(
      title: 'Customer Information',
      children: [
        _buildInfoRow('Name', '${job.data!.customerDetails!.firstName} ${job.data!.customerDetails!.lastName}'),
        SizedBox(height: 12.h),
        _buildInfoRow('Email', job.data!.customerDetails!.email ?? 'No email provided'),
        SizedBox(height: 12.h),
        _buildInfoRow('Phone', '${job.data!.customerDetails!.telephonePrefix} ${job.data!.customerDetails!.telephone}'),
        SizedBox(height: 12.h),
        _buildInfoSection(
          'Address',
          job.data!.customerDetails!.shippingAddress != null ? _getCustomerAddress(job) : 'No address provided',
        ),
      ],
    );
  }

  Widget _buildFinancialInfoCard(SingleJobModel job) {
    return _buildInfoCard(
      title: 'Financial Information',
      children: [
        _buildInfoRow('Subtotal', '\$${job.data!.subTotal!.toStringAsFixed(2)}'),
        SizedBox(height: 8.h),
        _buildInfoRow('VAT', '\$${job.data!.vat!.toStringAsFixed(2)}'),
        SizedBox(height: 8.h),
        _buildInfoRow('Discount', '\$${job.data!.discount!.toStringAsFixed(2)}'),
        SizedBox(height: 8.h),
        _buildInfoRow('Total', '\$${job.data!.total!.toStringAsFixed(2)}', isTotal: true),
      ],
    );
  }

  String _getCustomerAddress(SingleJobModel job) {
    final address = job.data!.customerDetails!.shippingAddress;
    return '${address != null ? address.street : ''} ${address?.sId}, ${address?.zip} ${address?.city}, ${address?.country}';
  }

  // All existing UI helper methods remain the same...
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

  Widget _buildInfoCard({required List<Widget> children, String? title}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            SizedBox(height: 12.h),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? Colors.green : Colors.black87,
          ),
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
          value: value.isNotEmpty ? value : null,
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

  Widget _buildTabCard(SingleJobModel job) {
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
            child: _selectedTabIndex == 0 ? _jobDetailsCardContent(job) : _deviceDetailsCardContent(job),
          ),
        ],
      ),
    );
  }
}
