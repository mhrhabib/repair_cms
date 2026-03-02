import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/widgets/job_card_widget.dart';
import 'package:repair_cms/features/myJobs/widgets/job_details_screen.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/myJobs/models/assign_user_list_model.dart';
import 'package:solar_icons/solar_icons.dart';

class MyJobsScreen extends StatefulWidget {
  final String? initialStatus;
  const MyJobsScreen({super.key, this.initialStatus});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  bool _hasLoadedInitially = false;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchOverlay = false;

  // Filter states
  String _sortBy = 'Last_created';
  String _location = 'My location';
  String _status = 'All';
  String _priority = 'All';
  String _dueDate = 'None';
  String _assignee = 'None';

  // Active filters list
  List<String> _activeFilters = [];

  // Assignee options
  List<String> _assigneeOptions = ['None'];
  List<User> _assigneeUsers = [];

  @override
  void initState() {
    super.initState();

    // Load initial jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
      _fetchAssignees();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedInitially && ModalRoute.of(context)?.isCurrent == true) {
      debugPrint('🔄 [MyJobsScreen] Screen is now active, reloading jobs');
      _loadJobs();
    }
    _hasLoadedInitially = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAssignees() async {
    try {
      final userId = storage.read('userId');
      if (userId != null) {
        final repository = context.read<JobCubit>().repository;
        final response = await repository.getAssignUserList(userId);

        if (mounted) {
          final names = response.data
              .map(
                (u) => u.fullName?.isNotEmpty == true ? u.fullName! : u.email,
              )
              .toList();

          setState(() {
            _assigneeUsers = response.data;
            _assigneeOptions = ['None', ...names];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching assignees: $e');
    }
  }

  void _loadJobs() {
    if (!mounted) {
      debugPrint('⚠️ [MyJobsScreen] Widget not mounted, skipping load');
      return;
    }

    try {
      debugPrint('📋 [MyJobsScreen] Loading jobs');
      if (widget.initialStatus != null && widget.initialStatus!.isNotEmpty) {
        context.read<JobCubit>().filterJobsByStatus(widget.initialStatus!);
      } else {
        // Explicitly reset the status filter so stale dashboard filters don't carry over
        context.read<JobCubit>().getJobs(statusList: []);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [MyJobsScreen] Error loading jobs: $e');
      debugPrint('📋 Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with Search
                if (_activeFilters.isEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                      child: GestureDetector(
                        onTap: () => _showFilterBottomSheet(context),
                        child: Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            SolarIconsOutline.sortVertical,
                            color: const Color(0xFF3B82F6),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Fixed left icon
                          Icon(
                            SolarIconsOutline.sortVertical,
                            color: const Color(0xFF3B82F6),
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          // Scrollable middle section with filters
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _activeFilters.join(', '),
                                style: GoogleFonts.roboto(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Fixed right close button
                          GestureDetector(
                            onTap: () => _clearAllFilters(),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  color: const Color(0xFFF5F7FA),
                  padding: EdgeInsets.fromLTRB(20.w, 1.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Sort Icon
                      Text(
                        'Jobs',
                        style: GoogleFonts.roboto(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Search Bar
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showSearchOverlay = true;
                          });
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: const Color(0xFF94A3B8),
                                size: 22.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Customer, Job-ID, Device ....',
                                style: GoogleFonts.roboto(
                                  fontSize: 15.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Job List
                Expanded(child: _buildJobList()),
              ],
            ),
          ),

          // Search Overlay
          if (_showSearchOverlay) _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    return BlocBuilder<JobCubit, JobStates>(
      builder: (context, state) {
        if (state is JobLoading) {
          return Center(
            child: CupertinoActivityIndicator(
              color: const Color(0xFF3B82F6),
              radius: 16.r,
            ),
          );
        }

        if (state is JobError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading jobs',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<JobCubit>().getJobs();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is JobSuccess) {
          final jobs = state.jobs;

          if (jobs.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Text(
                  'No jobs found',
                  style: GoogleFonts.roboto(
                    fontSize: 16.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: state.hasMore ? jobs.length + 1 : jobs.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index == jobs.length && state.hasMore) {
                context.read<JobCubit>().loadMoreJobs();
                return Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: const Color(0xFF3B82F6),
                      radius: 16.r,
                    ),
                  ),
                );
              }

              final job = jobs[index];
              return JobCardWidget(job: job);
            },
          );
        }

        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Text(
              'No jobs available',
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateActiveFilters() {
    List<String> filters = [];

    if (_location != 'My location') {
      filters.add(_location);
    }
    if (_status != 'All') {
      filters.add(_status);
    }
    if (_priority != 'All') {
      filters.add(_priority);
    }
    if (_assignee != 'None') {
      filters.add(_assignee);
    }
    if (_dueDate != 'None') {
      filters.add(_dueDate);
    }

    setState(() {
      _activeFilters = filters;
    });

    // Calculate date range based on _dueDate
    String? startDate;
    String? endDate;

    final now = DateTime.now();
    if (_dueDate == 'Today') {
      startDate = intl.DateFormat('yyyy-MM-dd').format(now);
      endDate = startDate;
    } else if (_dueDate == 'This week') {
      // Find the first day of the week (Monday)
      final firstDay = now.subtract(Duration(days: now.weekday - 1));
      final lastDay = firstDay.add(const Duration(days: 6));
      startDate = intl.DateFormat('yyyy-MM-dd').format(firstDay);
      endDate = intl.DateFormat('yyyy-MM-dd').format(lastDay);
    } else if (_dueDate == 'This month') {
      startDate = intl.DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(now.year, now.month, 1));
      endDate = intl.DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(now.year, now.month + 1, 0));
    }
    // 'Overdue' would require different logic (endDate < today), handled by backend ideally or simple date check

    // Map UI values to Backend values
    String? backendPriority;
    if (_priority != 'All') {
      backendPriority = _priority.toLowerCase();
    }

    String? backendStatus;
    if (_status != 'All') {
      switch (_status) {
        case 'Booked In':
          backendStatus = 'booked';
          break;
        case 'In Progress':
          backendStatus = 'in_progress';
          break;
        case 'Quote Accepted':
          backendStatus = 'accepted_quotes';
          break;
        case 'Quote Rejected':
          backendStatus = 'rejected_quotes';
          break;
        case 'Parts not available':
          backendStatus = 'parts_not_available';
          break;
        case 'Ready To Return':
          backendStatus = 'ready_to_return';
          break;
        default:
          backendStatus = _status;
      }
    }

    String? backendDueDate;
    if (_dueDate != 'None') {
      backendDueDate = _dueDate.toLowerCase().replaceAll(' ', '_');
    }

    // Get Assignee ID from Name
    String? assignUserId;
    if (_assignee != 'None') {
      try {
        final user = _assigneeUsers.firstWhere(
          (u) =>
              (u.fullName?.isNotEmpty == true ? u.fullName! : u.email) ==
              _assignee,
        );
        assignUserId = user.id;
      } catch (e) {
        debugPrint('Assignee not found for name: $_assignee');
      }
    }

    context.read<JobCubit>().getJobs(
      sortBy: _sortBy,
      location: _location,
      statusList: backendStatus != null
          ? [backendStatus]
          : ['accepted_quotes', 'booked'],
      priority: backendPriority,
      assignee: assignUserId,
      dueDate: backendDueDate,
      startDate: startDate,
      endDate: endDate,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _sortBy = 'Last created';
      _location = 'My location';
      _status = 'All';
      _priority = 'All';
      _dueDate = 'None';
      _assignee = 'None';
      _activeFilters = [];
    });
    context.read<JobCubit>().clearFilters();
  }

  Widget _buildSearchOverlay() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: GoogleFonts.roboto(
                          fontSize: 16.sp,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Customer, Job-ID, Device ....',
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 16.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color(0xFF64748B),
                            size: 22.sp,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                    context
                                        .read<JobCubit>()
                                        .clearSearchKeyword();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCBD5E1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        onChanged: (query) {
                          setState(() {});
                          if (query.isNotEmpty) {
                            context.read<JobCubit>().searchJobs(query);
                          } else {
                            context.read<JobCubit>().clearSearchKeyword();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Close Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSearchOverlay = false;
                        _searchController.clear();
                      });
                      context.read<JobCubit>().clearSearchKeyword();
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFF64748B),
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: BlocBuilder<JobCubit, JobStates>(
                builder: (context, state) {
                  if (state is JobLoading) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: const Color(0xFF3B82F6),
                        radius: 16.r,
                      ),
                    );
                  }

                  if (state is JobSuccess) {
                    final jobs = state.jobs;

                    if (jobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: const Color(0xFF64748B),
                                size: 28.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No Jobs found',
                              style: GoogleFonts.roboto(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Please verify your input or filters',
                              style: GoogleFonts.roboto(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return _buildSearchResultItem(job);
                      },
                    );
                  }

                  if (state is JobError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Error: ${state.message}',
                            style: GoogleFonts.roboto(
                              fontSize: 14.sp,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(Job job) {
    final searchQuery = _searchController.text.toLowerCase();
    final formattedDate = intl.DateFormat('dd.MM.yyyy').format(job.createdAt);
    final customerName =
        '${job.customerDetails.firstName} ${job.customerDetails.lastName}'
            .trim();
    final deviceBrand = job.deviceData.brand ?? '';
    final deviceModel = job.deviceData.model ?? '';
    final deviceInfo = '$deviceBrand $deviceModel'.trim();
    final employeeName = job.assignerName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _showSearchOverlay = false;
          _searchController.clear();
        });
        context.read<JobCubit>().clearKeywordOnly();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(jobId: job.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date, Status, and Priority Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _getStatusText(job),
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(job),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _getPriorityText(job),
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.flag,
                      color: _getPriorityColor(job),
                      size: 16.sp,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Job ID and Customer Name with highlighting
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _highlightText(
                        'JOB ID ${job.jobNo} | $customerName',
                        searchQuery,
                        GoogleFonts.roboto(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
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
              children: [
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      employeeName.isNotEmpty
                          ? employeeName[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.roboto(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  employeeName,
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    deviceInfo.isNotEmpty ? deviceInfo : 'Unknown Device',
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
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

  List<TextSpan> _highlightText(
    String text,
    String query,
    TextStyle baseStyle,
  ) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = lowerText.indexOf(lowerQuery, start)) != -1) {
      // Add text before highlight
      if (indexOfHighlight > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, indexOfHighlight),
            style: baseStyle,
          ),
        );
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + query.length,
          ),
          style: baseStyle.copyWith(
            backgroundColor: const Color(0xFFFEF3C7), // Yellow highlight
            color: const Color(0xFF1E293B),
          ),
        ),
      );

      start = indexOfHighlight + query.length;
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return spans;
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
      default:
        return status;
    }
  }

  Color _getStatusColor(Job job) {
    final status = job.status.toLowerCase().trim();
    switch (status) {
      case 'booked':
        return const Color(0xFF3B82F6);
      case 'in progress':
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'accepted_quotes':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getPriorityColor(Job job) {
    final priority = job.jobPriority?.toLowerCase() ?? 'neutral';
    switch (priority) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getPriorityText(Job job) {
    final priority = job.jobPriority?.toLowerCase() ?? 'neutral';
    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'high':
        return 'High';
      default:
        return 'Neutral';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              padding: EdgeInsets.only(
                top: 8.h,
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Sort by
                  _buildFilterRow(
                    'Sort by',
                    _sortBy,
                    () => _showSortByOptions(context, setModalState),
                  ),
                  SizedBox(height: 16.h),

                  // Location and Status
                  _buildDoubleFilterSection(
                    'Location',
                    _location,
                    () => _showLocationOptions(context, setModalState),
                    'Status',
                    _status,
                    () => _showStatusOptions(context, setModalState),
                  ),
                  SizedBox(height: 16.h),

                  // Priority and Due
                  _buildDoubleFilterSection(
                    'Priority',
                    _priority,
                    () => _showPriorityOptions(context, setModalState),
                    'Due',
                    _dueDate,
                    () => _showDueOptions(context, setModalState),
                  ),
                  SizedBox(height: 16.h),

                  // Assignee
                  _buildFilterRow(
                    'Assignee',
                    _assignee,
                    () => _showAssigneeOptions(context, setModalState),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _updateActiveFilters();
    });
  }

  Widget _buildFilterRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.unfold_more,
                  color: const Color(0xFF64748B),
                  size: 20.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleFilterSection(
    String label1,
    String value1,
    VoidCallback onTap1,
    String label2,
    String value2,
    VoidCallback onTap2,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildFilterRowInSection(label1, value1, onTap1),
          Divider(height: 24.h, thickness: 1, color: const Color(0xFFCBD5E1)),
          _buildFilterRowInSection(label2, value2, onTap2),
        ],
      ),
    );
  }

  Widget _buildFilterRowInSection(
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E293B),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.unfold_more,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSortByOptions(BuildContext context, StateSetter setModalState) {
    _showOptionsDialog(
      context,
      'Sort by',
      ['Last created', 'First created', 'Due date', 'Priority'],
      _sortBy,
      (value) {
        setState(() => _sortBy = value);
        setModalState(() => _sortBy = value);
      },
    );
  }

  void _showLocationOptions(BuildContext context, StateSetter setModalState) {
    _showOptionsDialog(
      context,
      'Location',
      ['My location', 'All locations'],
      _location,
      (value) {
        setState(() => _location = value);
        setModalState(() => _location = value);
      },
    );
  }

  void _showStatusOptions(BuildContext context, StateSetter setModalState) {
    _showOptionsDialog(
      context,
      'Status',
      [
        'All',
        'Booked In',
        'In Progress',
        'Quote Accepted',
        'Quote Rejected',
        'Parts not available',
        'Ready To Return',
      ],
      _status,
      (value) {
        setState(() => _status = value);
        setModalState(() => _status = value);
      },
    );
  }

  void _showPriorityOptions(BuildContext context, StateSetter setModalState) {
    _showOptionsDialog(
      context,
      'Priority',
      ['All', 'Urgent', 'High', 'Neutral'],
      _priority,
      (value) {
        setState(() => _priority = value);
        setModalState(() => _priority = value);
      },
    );
  }

  void _showDueOptions(BuildContext context, StateSetter setModalState) {
    _showOptionsDialog(
      context,
      'Due',
      ['None', 'Today', 'This week', 'This month', 'Overdue'],
      _dueDate,
      (value) {
        setState(() => _dueDate = value);
        setModalState(() => _dueDate = value);
      },
    );
  }

  void _showAssigneeOptions(BuildContext context, StateSetter setModalState) {
    _showOptionsDialog(context, 'Assignee', _assigneeOptions, _assignee, (
      value,
    ) {
      setState(() => _assignee = value);
      setModalState(() => _assignee = value);
    });
  }

  void _showOptionsDialog(
    BuildContext context,
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                Divider(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option == currentValue;
                      return ListTile(
                        title: Text(
                          option,
                          style: GoogleFonts.roboto(
                            fontSize: 16.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: const Color(0xFF3B82F6),
                                size: 24.sp,
                              )
                            : null,
                        onTap: () {
                          onSelect(option);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
