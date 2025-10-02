import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/myJobs/widgets/job_card_widget.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/repository/job_repository.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['My\nJobs', 'All\nJobs', 'Rejected\nQuotes', 'Completed\nJobs'];
  final List<Color> _tabColors = [Colors.grey, Colors.blue, Colors.red, Colors.green];

  // Status filters for each tab
  final List<String> _tabStatusFilters = ['', '', 'rejected', 'complete'];

  @override
  void initState() {
    super.initState();
    // Load initial jobs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobCubit>().getJobs();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    // Filter jobs based on selected tab
    final statusFilter = _tabStatusFilters[index];
    if (statusFilter.isNotEmpty) {
      context.read<JobCubit>().filterJobsByStatus(statusFilter);
    } else {
      context.read<JobCubit>().clearFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const Icon(Icons.search, color: Colors.black87),
            title: const Text(
              'My Jobs',
              style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
                icon: const Icon(Icons.filter_list, color: Colors.black87),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: Colors.black87),
              ),
            ],
            pinned: true,
            floating: false,
            snap: false,
          ),

          // Custom Tab Bar
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFD9E1EA),
              height: 60.h,
              padding: EdgeInsets.only(left: 12.w),
              child: BlocBuilder<JobCubit, JobStates>(
                builder: (context, state) {
                  int totalJobs = 0;
                  int completedJobs = 0;
                  int rejectedJobs = 0;
                  int allJobs = 0;

                  if (state is JobSuccess) {
                    totalJobs = state.totalJobs;
                    completedJobs = state.jobs.where((job) => job.status.toLowerCase() == 'complete').length;
                    rejectedJobs = state.jobs.where((job) => job.status.toLowerCase() == 'rejected').length;
                    allJobs = state.jobs.length;
                  }

                  final List<int> _itemCounts = [
                    allJobs, // My Jobs (all visible jobs)
                    totalJobs, // All Jobs (total from API)
                    rejectedJobs, // Rejected Quotes
                    completedJobs, // Completed Jobs
                  ];

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabTitles.length,
                    separatorBuilder: (context, index) => Container(
                      width: 2.w,
                      height: 40.h,
                      color: Colors.grey.withValues(alpha: 0.3),
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () => _onTabChanged(index),
                        child: Container(
                          margin: EdgeInsets.only(top: 1.h, bottom: 1.h, left: 4.w, right: 4.w),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                height: 40.h,
                                width: 40.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: _tabColors[index]),
                                child: Text(
                                  _itemCounts[index].toString(),
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              SizedBox(
                                child: Text(
                                  _tabTitles[index],
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: Colors.black87,
                                  ),
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
    );
  }

  Widget _buildJobListSliver() {
    return BlocBuilder<JobCubit, JobStates>(
      builder: (context, state) {
        if (state is JobLoading) {
          return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
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
                  child: Text('No jobs found', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                padding: EdgeInsets.only(top: index == 0 ? 16.h : 0, bottom: 16.h, left: 16.w, right: 16.w),
                child: JobCardWidget(job: job),
              );
            }, childCount: state.hasMore ? jobs.length + 1 : jobs.length),
          );
        }

        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No jobs available', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              // Add filter options here (date range, status, etc.)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<JobCubit>().clearFilters();
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}
