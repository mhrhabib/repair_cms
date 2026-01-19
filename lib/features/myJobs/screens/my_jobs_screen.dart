import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:feather_icons/feather_icons.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/widgets/job_card_widget.dart';
import 'package:repair_cms/features/myJobs/widgets/job_details_screen.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';

class MyJobsScreen extends StatefulWidget {
  final String? initialStatus;
  const MyJobsScreen({super.key, this.initialStatus});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late int _selectedTabIndex;
  bool _showSearchOverlay = false;
  bool _hasLoadedInitially = false;

  // Updated tab configuration with all status filters
  final List<TabConfig> _tabs = [
    TabConfig(title: 'All\nJobs', color: Colors.blue, status: ''),
    TabConfig(
      title: 'Repair in\nProgress',
      color: Colors.orange,
      status: 'in_progress',
    ),
    TabConfig(title: 'Rejected\nQuotes', color: Colors.red, status: 'rejected'),
    TabConfig(
      title: 'Quotation\nAccepted',
      color: Colors.green,
      status: 'accepted_quotes',
    ),
    TabConfig(
      title: 'Parts Not\nAvailable',
      color: Colors.purple,
      status: 'parts_not_available',
    ),
    TabConfig(
      title: 'Ready To\nReturn',
      color: Colors.teal,
      status: 'ready_to_return',
    ),
    TabConfig(title: 'Archive', color: Colors.grey, status: 'archive'),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize selected tab based on initialStatus
    _selectedTabIndex = 0;
    if (widget.initialStatus != null && widget.initialStatus!.isNotEmpty) {
      final index = _tabs.indexWhere(
        (tab) => tab.status == widget.initialStatus,
      );
      if (index != -1) {
        _selectedTabIndex = index;
      }
    }

    // Load initial jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload jobs whenever the screen becomes visible again (but not on first load)
    // This ensures fresh data when navigating back from job details
    if (_hasLoadedInitially && ModalRoute.of(context)?.isCurrent == true) {
      debugPrint('🔄 [MyJobsScreen] Screen is now active, reloading jobs');
      _loadJobs();
    }
    _hasLoadedInitially = true;
  }

  void _loadJobs() {
    if (!mounted) {
      debugPrint('⚠️ [MyJobsScreen] Widget not mounted, skipping load');
      return;
    }

    try {
      debugPrint(
        '📋 [MyJobsScreen] Loading jobs for tab index: $_selectedTabIndex',
      );
      if (widget.initialStatus != null && widget.initialStatus!.isNotEmpty) {
        context.read<JobCubit>().filterJobsByStatus(widget.initialStatus!);
      } else {
        final statusFilter = _tabs[_selectedTabIndex].status;
        if (statusFilter.isEmpty) {
          context.read<JobCubit>().getJobs();
        } else {
          context.read<JobCubit>().filterJobsByStatus(statusFilter);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [MyJobsScreen] Error loading jobs: $e');
      debugPrint('📋 Stack trace: $stackTrace');
    }
  }

  void _onTabChanged(int index) {
    if (!mounted) {
      debugPrint('⚠️ [MyJobsScreen] Widget not mounted, skipping tab change');
      return;
    }

    try {
      debugPrint('🔄 [MyJobsScreen] Tab changed to index: $index');
      setState(() {
        _selectedTabIndex = index;
      });

      // Filter jobs based on selected tab
      final statusFilter = _tabs[index].status;
      context.read<JobCubit>().filterJobsByStatus(statusFilter);
    } catch (e) {
      debugPrint('❌ [MyJobsScreen] Error changing tab: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leadingWidth: Navigator.of(context).canPop() ? 80.w : 56.w,
                leading: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (Navigator.of(context).canPop())
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black87,
                          ),
                        ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showSearchOverlay = true;
                          });
                        },
                        icon: const Icon(Icons.search, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                title: const Text(
                  'My Jobs',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  // IconButton(
                  //   onPressed: () {
                  //     _showFilterBottomSheet(context);
                  //   },
                  //   icon: const Icon(Icons.filter_list, color: Colors.black87),
                  // ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.menu, color: Colors.black87),
                  // ),
                ],
                pinned: true,
                floating: false,
                snap: false,
              ),

              // Custom Tab Bar
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFD9E1EA),
                  height: 70.h,
                  padding: EdgeInsets.only(left: 12.w),
                  child: BlocBuilder<JobCubit, JobStates>(
                    builder: (context, state) {
                      // Calculate counts for each tab
                      final counts = _calculateTabCounts(state);

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabs.length,
                        separatorBuilder: (context, index) => Container(
                          width: 2.w,
                          height: 40.h,
                          color: Colors.grey.withValues(alpha: 0.3),
                          margin: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedTabIndex == index;
                          final tab = _tabs[index];
                          final count = counts[index];

                          return GestureDetector(
                            onTap: () => _onTabChanged(index),
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 1.h,
                                bottom: 1.h,
                                left: 4.w,
                                right: 4.w,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(2, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    height: 40.h,
                                    width: 40.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: tab.color,
                                    ),
                                    child: Text(
                                      count.toString(),
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      tab.title,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Job List
              _buildJobListSliver(),
            ],
          ),

          // Search Overlay
          if (_showSearchOverlay)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: SafeArea(
                child: Column(
                  children: [
                    // Search Header
                    Container(
                      color: const Color(0xFF4A5568),
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          // Search Field
                          Expanded(
                            child: Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                autofocus: true,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: 'Search job',
                                  hintStyle: AppTypography.fontSize16.copyWith(
                                    color: AppColors.lightFontColor,
                                  ),
                                  prefixIcon: Icon(
                                    FeatherIcons.search,
                                    color: Colors.black,
                                    size: 22.sp,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onChanged: (query) {
                                  debugPrint(
                                    '🔍 [MyJobsScreen] Search query: $query',
                                  );
                                  if (query.isNotEmpty) {
                                    context.read<JobCubit>().searchJobs(query);
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Cancel Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showSearchOverlay = false;
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: AppTypography.fontSize16.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
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
                          if (state is JobLoading ||
                              state is JobActionLoading) {
                            return Container(
                              color: Colors.white,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.fontMainColor,
                                ),
                              ),
                            );
                          }

                          if (state is JobSuccess) {
                            final jobs = state.jobs;
                           
                            return Container(
                              color: Colors.white,
                              child: ListView.builder(
                                itemCount: jobs.length,
                                itemBuilder: (context, index) {
                                  final job = jobs[index];
                                  final formattedDate = intl.DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(job.createdAt);
                                  final customerName =
                                      '${job.customerDetails.firstName} ${job.customerDetails.lastName}'
                                          .trim();
                                  final deviceBrand =
                                      job.deviceData.brand ?? '';
                                  final deviceModel =
                                      job.deviceData.model ?? '';
                                  final deviceInfo = '$deviceBrand $deviceModel'
                                      .trim();

                                  return GestureDetector(
                                    onTap: () {
                                      if (!mounted) return;
                                      try {
                                        debugPrint(
                                          '🔍 [MyJobsScreen] Navigating to job: ${job.id}',
                                        );
                                        setState(() {
                                          _showSearchOverlay = false;
                                        });
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                JobDetailsScreen(jobId: job.id),
                                          ),
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          '❌ [MyJobsScreen] Error navigating: $e',
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: const Color(0xFFDEE3E8),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                job.jobNo,
                                                style: AppTypography.fontSize16
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors
                                                          .fontMainColor,
                                                    ),
                                              ),
                                              if (customerName.isNotEmpty)
                                                Text(
                                                  ' | $customerName',
                                                  style: AppTypography
                                                      .fontSize16
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .fontMainColor,
                                                      ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '$formattedDate${deviceInfo.isNotEmpty ? ' | $deviceInfo' : ''}',
                                            style: AppTypography.fontSize14
                                                .copyWith(
                                                  color:
                                                      AppColors.lightFontColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                            
                          }
                         if(state is JobSuccess){
                          final jobs = state.jobs;
                            if (jobs.isEmpty) {
                              return Container(
                                color: Colors.white,
                                child: Center(
                                  child: Text(
                                    'No jobs found',
                                    style: AppTypography.fontSize16.copyWith(
                                      color: AppColors.lightFontColor,
                                    ),
                                  ),
                                ),
                              );
                            }
                         }

                          if (state is JobError) {
                            return Container(
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  'Error: ${state.message}',
                                  style: AppTypography.fontSize14.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
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
            ),
        ],
      ),
    );
  }

  List<int> _calculateTabCounts(JobStates state) {
    if (state is JobSuccess) {
      final jobs = state.response;
      return [
        state.totalJobs, // All Jobs (total from API)
        jobs.inProgressJobs,
        jobs.rejectQuoetsJobs,
        jobs.acceptedQuoetsJobs,
        jobs.partsNotAvailableJobs,
        jobs.readyToReturnJobs,
        jobs.totalServiceRequestArchive,
      ];
    }

    // Return zeros if no data
    return List.filled(_tabs.length, 0);
  }

  Widget _buildJobListSliver() {
    return BlocBuilder<JobCubit, JobStates>(
      builder: (context, state) {
        if (state is JobLoading) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is JobError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading jobs',
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<JobCubit>().getJobs();
                    },
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
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'No jobs found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == jobs.length && state.hasMore) {
                // Load more indicator
                context.read<JobCubit>().loadMoreJobs();
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final job = jobs[index];
              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 16.h : 0,
                  bottom: 16.h,
                ),
                child: JobCardWidget(job: job),
              );
            }, childCount: state.hasMore ? jobs.length + 1 : jobs.length),
          );
        }

        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No jobs available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }

//   void _showFilterBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Filter Jobs',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16.h),
//               // Add filter options here (date range, status, etc.)
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.read<JobCubit>().clearFilters();
//                 },
//                 child: const Text('Clear Filters'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
 }

// Helper class for tab configuration
class TabConfig {
  final String title;
  final Color color;
  final String status;

  TabConfig({required this.title, required this.color, required this.status});
}
