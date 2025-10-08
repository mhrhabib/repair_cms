import 'dart:ui';

import 'package:feather_icons/feather_icons.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/notifications/notifications_screen.dart';
import 'package:repair_cms/features/profile/profile_options_screen.dart';

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
  List<JobSearchResult> _searchResults = [];

  // Sample data - replace with your actual data source
  final List<JobSearchResult> _allJobs = [
    JobSearchResult(
      jobId: "JOB-ID:120820084",
      customerName: "Zafer Gürsoy",
      date: "10.03.2024",
      device: "iPhone 13 Pro Max",
    ),
    JobSearchResult(
      jobId: "JOB-ID:120820085",
      customerName: "Zafer Gürsoy",
      date: "10.03.2024",
      device: "iPhone 13 Pro Max",
    ),
    JobSearchResult(
      jobId: "JOB-ID:120820086",
      customerName: "Zafer Gürsoy",
      date: "10.03.2024",
      device: "iPhone 13 Pro Max",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allJobs
            .where(
              (job) =>
                  job.jobId.toLowerCase().contains(query) ||
                  job.customerName.toLowerCase().contains(query) ||
                  job.device.toLowerCase().contains(query),
            )
            .toList();
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
      _searchResults = [];
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
                child: CircleAvatar(
                  radius: 16.r,
                  backgroundImage: const AssetImage('assets/images/logo.png'),
                  backgroundColor: Colors.grey.shade300,
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
                      color: Colors.white.withOpacity(0.2),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
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

        // Search Results
        if (_searchResults.isNotEmpty) _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final job = _searchResults[index];
          return _buildSearchResultItem(job);
        },
      ),
    );
  }

  Widget _buildSearchResultItem(JobSearchResult job) {
    return Container(
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
                job.jobId,
                style: AppTypography.fontSize16.copyWith(fontWeight: FontWeight.w500, color: AppColors.fontMainColor),
              ),
              Text(
                ' | ${job.customerName}',
                style: AppTypography.fontSize16.copyWith(fontWeight: FontWeight.w500, color: AppColors.fontMainColor),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '${job.date} | ${job.device}',
            style: AppTypography.fontSize14.copyWith(color: AppColors.lightFontColor),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

class JobSearchResult {
  final String jobId;
  final String customerName;
  final String date;
  final String device;

  JobSearchResult({required this.jobId, required this.customerName, required this.date, required this.device});
}
