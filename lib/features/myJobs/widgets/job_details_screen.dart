// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/job_details_navbar_screen.dart';
import 'package:repair_cms/features/myJobs/models/assign_user_list_model.dart';
import 'package:repair_cms/features/myJobs/models/single_job_model.dart';
import 'package:repair_cms/features/myJobs/widgets/files_screen.dart';
import 'package:repair_cms/features/myJobs/widgets/job_complete_bottomsheet.dart';
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
  SingleJobModel? _currentJob;

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
          setState(() {
            _currentJob = state.job; // Cache the job
          });
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
              // If we have a cached job, show it regardless of loading states
              if (_currentJob != null &&
                  (state is AssignUserListLoading || state is AssignUserListSuccess || state is AssignUserListError)) {
                return _buildCurrentScreen(_currentJob!);
              }

              if (state is JobLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is JobDetailSuccess) {
                return _buildCurrentScreen(state.job);
              } else if (state is JobError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              return const Center(child: CircularProgressIndicator());

              // Fallback
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
        return StatusScreen(jobId: job);
      case 3:
        return NotesScreen(job: job);
      case 4:
        return FilesScreen(jobId: job);
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
  // Add these variables for user management
  List<User> _availableUsers = [];
  bool _isLoadingUsers = false;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    // Initialize both job complete and return device status from actual job data
    _initializeJobStatus();
    _loadAvailableUsers();
  }

  // Add this method to load users

  void _loadAvailableUsers() {
    setState(() {
      _isLoadingUsers = true;
    });

    // Listen to the user list state
    context.read<JobCubit>().getAssignUserList();
  }

  void _setCurrentAssignee() {
    final jobData = widget.job.data!;

    if (jobData.assignUser != null && jobData.assignUser!.isNotEmpty) {
      final assignUser = jobData.assignUser!.first;

      String assignUserId;
      String assigneeName = 'Select assignee';

      // Check if assignUser is a Map (object) or a String
      if (assignUser is Map) {
        // Extract the ID from the user object
        assignUserId = assignUser['_id']?.toString() ?? '';
        assigneeName = assignUser['fullName'] ?? assignUser['email'] ?? 'Unknown User';
        debugPrint('🔄 AssignUser is a Map, extracted ID: $assignUserId, Name: $assigneeName');
      } else if (assignUser is String) {
        // It's already a string ID - find the name from available users
        assignUserId = assignUser;
        final user = _findUserById(assignUserId);
        assigneeName = user?.fullName ?? user?.email ?? 'Unknown User';
        debugPrint('🔄 AssignUser is a String ID: $assignUserId, Found Name: $assigneeName');
      } else {
        assignUserId = assignUser.toString();
        assigneeName = 'Unknown User';
        debugPrint('⚠️ AssignUser is unknown type: ${assignUser.runtimeType}');
      }

      if (assignUserId.isNotEmpty) {
        setState(() {
          selectedAssignee = assigneeName; // Display name
          _selectedUserId = assignUserId; // Store ID for dropdown value
        });

        debugPrint('✅ Current assignee set - Display: $selectedAssignee, ID: $_selectedUserId');
      } else {
        debugPrint('❌ Empty assignee ID found');
        setState(() {
          _selectedUserId = null;
          selectedAssignee = 'Select assignee';
        });
      }
    } else {
      debugPrint('ℹ️ No assignee set for this job');
      setState(() {
        _selectedUserId = null;
        selectedAssignee = 'Select assignee';
      });
    }
  }

  User? _findUserById(String userId) {
    try {
      return _availableUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  void _onAssigneeSelected(String? newUserId) {
    if (newUserId != null && newUserId.isNotEmpty) {
      debugPrint('🔄 Selecting user with ID: $newUserId');

      // Find the selected user by ID to get their name for display
      final selectedUser = _findUserById(newUserId);

      if (selectedUser != null) {
        final userName = selectedUser.fullName ?? selectedUser.email;

        setState(() {
          selectedAssignee = userName; // Update display name
          _selectedUserId = newUserId; // Store the ID for dropdown value
        });

        debugPrint('✅ User selected - Display: $userName, ID: $newUserId');

        // Pass the ID to the API
        context.read<JobCubit>().updateJobAssignee(widget.job.data!.sId!, newUserId, userName);
        SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
      } else {
        debugPrint('❌ User not found with ID: $newUserId');
        debugPrint('Available user IDs: ${_availableUsers.map((u) => u.id).join(", ")}');

        // Fallback: still update with the ID
        setState(() {
          _selectedUserId = newUserId;
          selectedAssignee = 'User ($newUserId)'; // Show ID in name if user not found
        });

        // Pass the ID to the API even if user not found locally
        context.read<JobCubit>().updateJobAssignee(widget.job.data!.sId!, newUserId, 'Unknown User');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Assigned to user ID: $newUserId'), backgroundColor: Colors.orange));
      }
    } else {
      debugPrint('ℹ️ No user selected or empty user ID');
      setState(() {
        _selectedUserId = null;
        selectedAssignee = 'Select assignee';
      });
    }
  }

  void _initializeJobStatus() {
    final jobData = widget.job.data!;

    // Initialize job complete status
    isJobComplete = jobData.isJobCompleted != null && jobData.isJobCompleted! == true;

    // Initialize return device status
    returnDevice = jobData.isDeviceReturned != null && jobData.isDeviceReturned! == true;

    // Initialize due date from job data
    if (jobData.dueDate != null && jobData.dueDate!.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(jobData.dueDate!);
        selectedDueDate = "${parsedDate.day}. ${_getMonthName(parsedDate.month)} ${parsedDate.year}";
      } catch (e) {
        selectedDueDate = 'Select due date';
      }
    } else {
      selectedDueDate = 'Select due date';
    }

    // Initialize priority from job data
    if (jobData.jobPriority != null && jobData.jobPriority!.isNotEmpty) {
      selectedPriority = _capitalizeFirstLetter(jobData.jobPriority!);
    } else {
      selectedPriority = 'Neutral';
    }

    // Initialize assignee from job data
    if (jobData.assignUser != null && jobData.assignUser!.isNotEmpty) {
      // If assignUser is a list, get the first item
      if (jobData.assignUser is List) {
        final assignList = jobData.assignUser as List;
        if (assignList.isNotEmpty && assignList.first is String) {
          selectedAssignee = assignList.first;
        } else {
          selectedAssignee = 'Susan Lemmes';
        }
      } else if (jobData.assignUser is String) {
        selectedAssignee = jobData.assignUser as String;
      } else {
        selectedAssignee = 'Susan Lemmes';
      }
    } else {
      selectedAssignee = 'Susan Lemmes';
    }

    print('Job ID in JobDetails: ${jobData.sId}');
    print('Job Complete Status: $isJobComplete');
    print('Return Device Status: $returnDevice');
    print('Job Priority: ${jobData.jobPriority}');
    print('Due Date: ${jobData.dueDate}');
    print('Assign User: ${jobData.assignUser}');
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void didUpdateWidget(JobDetailsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update when job prop changes
    if (oldWidget.job.data!.sId != widget.job.data!.sId) {
      _initializeJobStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building JobDetails with Job ID: ${widget.job.data!.sId}');

    return BlocListener<JobCubit, JobStates>(
      listener: (context, state) {
        if (state is JobDetailSuccess) {
          setState(() {
            _initializeJobStatus();
          });
        }
        if (state is JobStatusUpdated) {
          SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
        }
        if (state is AssignUserListSuccess) {
          setState(() {
            _availableUsers = state.users;
            _isLoadingUsers = false;
          });
          _setCurrentAssignee();
        }
        if (state is AssignUserListError) {
          setState(() {
            _isLoadingUsers = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load users: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },

      child: Scaffold(
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
      ),
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
                      if (value) {
                        // Setting job to complete - show bottom sheet for confirmation
                        _showCompleteConfirmationBottomSheet();
                      } else {
                        // Setting job to incomplete - update immediately with confirmation dialog
                        _showIncompleteConfirmationDialog();
                      }
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
                      if (value) {
                        // Setting device as returned - show confirmation
                        _showReturnDeviceConfirmationDialog();
                      } else {
                        // Setting device as not returned - update immediately
                        _setDeviceAsNotReturned();
                      }
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
                      onChanged: _onPrioritySelected,
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

                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 1.5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 20),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                selectedDueDate,
                                style: GoogleFonts.roboto(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Assignee
                    // Replace the assignee section with this:
                    Text(
                      'Assignee',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    _isLoadingUsers
                        ? Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, color: Colors.grey, size: 20),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Loading users...',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)),
                              ],
                            ),
                          )
                        : _buildUserDropdownField(),
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

  void _showCompleteConfirmationBottomSheet() {
    showJobCompleteBottomSheet(
      context,
      onConfirm: (String notes, bool sendNotification) {
        // Forward notes and the sendNotification flag from the bottom sheet
        context.read<JobCubit>().setJobAsComplete(
          jobId: widget.job.data!.sId!,
          userId: storage.read('userId'),
          userName: storage.read('fullName'),
          email: storage.read('email'),
          notes: notes,
          sendNotification: sendNotification,
          currentJob: widget.job,
        );

        // Update local state
        setState(() {
          isJobComplete = true;
        });

        SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
      },
    );
  }

  void _setDeviceAsReturned() {
    context.read<JobCubit>().setDeviceAsReturned(
      jobId: widget.job.data!.sId!,
      userId: storage.read('userId'),
      userName: storage.read('fullName'),
      email: storage.read('email'),
      notes: 'move to trash',
      sendNotification: true,
    );

    // Update local state
    setState(() {
      returnDevice = true;
    });

    SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
  }

  void _setDeviceAsNotReturned() {
    context.read<JobCubit>().setDeviceAsNotReturned(
      jobId: widget.job.data!.sId!,
      userId: storage.read('userId'),
      userName: storage.read('fullName'),
      email: storage.read('email'),
      notes: 'Device is in progress',
      sendNotification: true,
    );

    // Update local state
    setState(() {
      returnDevice = false;
    });

    SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
  }

  void _showReturnDeviceConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Mark Device as Returned?',
            style: GoogleFonts.roboto(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will:',
                style: GoogleFonts.roboto(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              Text(
                '• Mark device as returned',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              Text(
                '• Archive the job',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              Text(
                '• Move job to trash',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _setDeviceAsReturned();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                'Mark Returned',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showIncompleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Set Job as Incomplete?',
            style: GoogleFonts.roboto(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'This will change the job status to "In Progress" and mark it as incomplete.',
            style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<JobCubit>().setJobAsIncomplete(
                  jobId: widget.job.data!.sId!,
                  userId: storage.read('userId'),
                  userName: storage.read('fullName'),
                  email: storage.read('email'),
                  notes: 'Device is in progress',
                  sendNotification: true,
                  currentJob: widget.job,
                );

                // Update local state
                setState(() {
                  isJobComplete = false;
                });

                SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(
                'Mark Incomplete',
                style: GoogleFonts.roboto(fontSize: 14.sp, color: Colors.white),
              ),
            ),
          ],
        );
      },
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

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      // Update the due date
      context.read<JobCubit>().updateJobDueDate(widget.job.data!.sId!, picked);

      // Update local state
      setState(() {
        selectedDueDate = "${picked.day}. ${_getMonthName(picked.month)} ${picked.year}";
      });

      SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
    }
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

  // Add this method:
  void _onPrioritySelected(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedPriority = newValue;
      });

      // Convert to lowercase for API
      final priorityValue = newValue.toLowerCase();

      context.read<JobCubit>().updateJobPriority(widget.job.data!.sId!, priorityValue);

      SnackbarDemo(message: 'Job Updated Successfully').showCustomSnackbar(context);
    }
  }

  Widget _buildUserDropdownField() {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedUserId, // Store the ID, but display will show name
          onChanged: _onAssigneeSelected,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),
          isExpanded: true,
          hint: Text(
            'Select assignee',
            style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
          ),
          items: _availableUsers.map((User user) {
            final userName = user.fullName ?? user.email;
            final userInitials = _getUserInitials(userName);

            return DropdownMenuItem<String>(
              value: user.id, // This is the ID that gets passed to onChanged
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: Colors.blue,
                    child: Text(
                      userInitials,
                      style: GoogleFonts.roboto(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName, // Display the name
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        // if (userEmail.isNotEmpty)
                        //   Text(
                        //     userEmail,
                        //     style: GoogleFonts.roboto(
                        //       fontSize: 12.sp,
                        //       fontWeight: FontWeight.w400,
                        //       color: Colors.grey.shade600,
                        //     ),
                        //   ),
                      ],
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

  String _getUserInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}
