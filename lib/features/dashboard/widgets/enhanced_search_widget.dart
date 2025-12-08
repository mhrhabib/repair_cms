import 'dart:ui';
import 'dart:async';

import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart' as intl;
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/notifications/notifications_screen.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/profile_options_screen.dart';
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'package:repair_cms/features/myJobs/models/job_list_response.dart';
import 'package:repair_cms/features/myJobs/widgets/job_details_screen.dart';

class EnhancedSearchWidget extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final Function()? onQRScanPressed;

  const EnhancedSearchWidget({super.key, this.onSearchChanged, this.onQRScanPressed});

  @override
  State<EnhancedSearchWidget> createState() => _EnhancedSearchWidgetState();
}

class _EnhancedSearchWidgetState extends State<EnhancedSearchWidget> with SingleTickerProviderStateMixin {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  // Store the signed avatar URL
  String? _avatarSignedUrl;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load profile data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCubit = context.read<ProfileCubit>();
      profileCubit.loadUserFromStorage().then((_) {
        profileCubit.getUserProfile();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    debugPrint('🔍 [EnhancedSearchWidget] Search text changed: ${_searchController.text}');

    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final query = _searchController.text.trim();

    // Debounce API calls by 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      debugPrint('🌐 [EnhancedSearchWidget] Triggering search API for: $query');

      if (query.isNotEmpty) {
        // Call JobCubit to search jobs via API
        debugPrint('👤 [EnhancedSearchWidget] Searching jobs with keyword: $query');
        context.read<JobCubit>().searchJobs(query);
      }
    });

    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(query);
    }
  }

  void _activateSearch() {
    setState(() {
      _isSearchActive = true;
    });
    _searchFocusNode.requestFocus();
  }

  void _deactivateSearch() {
    setState(() {
      _isSearchActive = false;
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchActive) {
      return BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: _buildActiveSearchView());
    } else {
      return _buildInactiveSearchField();
    }
  }

  Widget _buildInactiveSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _activateSearch,
              child: Container(
                height: 40.h,
                width: 120.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFDEE3E8)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Icon(FeatherIcons.search, color: Colors.black, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text('Search job', style: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor)),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              // Search field will be handled by EnhancedSearchWidget overlay
              SizedBox(width: 12.w),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen()));
                    },
                    child: Icon(Icons.notifications_none, color: Colors.grey.shade600, size: 24.sp),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileOptionsScreen()));
                },
                child: BlocBuilder<ProfileCubit, ProfileStates>(
                  builder: (context, state) {
                    String? avatarUrl;
                    bool isLoading = false;

                    // Extract avatar URL from state
                    if (state is ProfileLoaded) {
                      avatarUrl = state.user.avatar;

                      // Fetch signed URL if we have an S3 path and haven't fetched it yet
                      if (avatarUrl != null &&
                          avatarUrl.isNotEmpty &&
                          !avatarUrl.startsWith('http') &&
                          _avatarSignedUrl == null) {
                        // Fetch signed URL in background
                        context
                            .read<ProfileCubit>()
                            .getImageUrl(avatarUrl)
                            .then((signedUrl) {
                              if (mounted) {
                                setState(() {
                                  _avatarSignedUrl = signedUrl;
                                });
                              }
                            })
                            .catchError((error) {
                              debugPrint('Failed to fetch avatar signed URL: $error');
                            });
                      }
                    } else if (state is ProfileLoading) {
                      isLoading = true;
                    }

                    return Stack(
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 16.r,
                          backgroundImage: _avatarSignedUrl != null && _avatarSignedUrl!.isNotEmpty
                              ? NetworkImage(_avatarSignedUrl!)
                              : (avatarUrl != null && avatarUrl.startsWith('http')
                                    ? NetworkImage(avatarUrl)
                                    : const AssetImage('assets/icon/icon.png') as ImageProvider),
                          backgroundColor: Colors.grey.shade300,
                          onBackgroundImageError: (exception, stackTrace) {
                            debugPrint('Profile image load error: $exception');
                          },
                        ),

                        // Loading indicator overlay
                        if (isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 12.r,
                                  height: 12.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSearchView() {
    return Column(
      children: [
        // Active search header
        Container(
          color: const Color(0xFF4A5568),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // QR Code Button
                GestureDetector(
                  onTap: widget.onQRScanPressed ?? () {},
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 24.sp),
                  ),
                ),
                SizedBox(width: 12.w),

                // Search Field
                Expanded(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search job',
                        hintStyle: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor),
                        prefixIcon: Icon(FeatherIcons.search, color: Colors.black, size: 22.sp),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                },
                                child: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Cancel Button
                GestureDetector(
                  onTap: _deactivateSearch,
                  child: Text(
                    'Cancel',
                    style: AppTypography.fontSize16.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search Results - using BlocBuilder to listen to JobCubit state
        BlocBuilder<JobCubit, JobStates>(
          builder: (context, state) {
            if (state is JobLoading || state is JobActionLoading) {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(24.h),
                child: Center(child: CircularProgressIndicator(color: AppColors.fontMainColor)),
              );
            }

            if (state is JobSuccess && _searchController.text.isNotEmpty) {
              final jobs = state.jobs;
              if (jobs.isEmpty) {
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(24.h),
                  child: Center(
                    child: Text(
                      'No jobs found',
                      style: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor),
                    ),
                  ),
                );
              }
              return _buildSearchResults(jobs);
            }

            if (state is JobError) {
              return Container(
                color: Colors.white,
                padding: EdgeInsets.all(24.h),
                child: Center(
                  child: Text('Error: ${state.message}', style: AppTypography.fontSize14.copyWith(color: Colors.red)),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<Job> jobs) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return _buildSearchResultItem(job);
        },
      ),
    );
  }

  Widget _buildSearchResultItem(Job job) {
    // Format date
    final formattedDate = intl.DateFormat('dd.MM.yyyy').format(job.createdAt);

    // Get customer name
    final customerName = '${job.customerDetails.firstName} ${job.customerDetails.lastName}'.trim();

    // Get device info
    final deviceBrand = job.deviceData.brand ?? '';
    final deviceModel = job.deviceData.model ?? '';
    final deviceInfo = '$deviceBrand $deviceModel'.trim();

    return GestureDetector(
      onTap: () {
        debugPrint('🔍 [EnhancedSearchWidget] Navigating to job details: ${job.id}');
        // Close search overlay
        _deactivateSearch();
        // Navigate to JobDetailsScreen
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => JobDetailsScreen(jobId: job.id)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: const Color(0xFFDEE3E8), width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  job.jobNo,
                  style: AppTypography.fontSize16.copyWith(fontWeight: FontWeight.w500, color: AppColors.fontMainColor),
                ),
                if (customerName.isNotEmpty)
                  Text(
                    ' | $customerName',
                    style: AppTypography.fontSize16.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.fontMainColor,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '$formattedDate${deviceInfo.isNotEmpty ? ' | $deviceInfo' : ''}',
              style: AppTypography.fontSize14.copyWith(color: AppColors.lightFontColor),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
