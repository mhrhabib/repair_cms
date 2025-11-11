import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/cubits/service/service_cubit.dart';
import 'package:repair_cms/features/jobBooking/models/service_response_model.dart';
import 'one/job_booking_start_booking_job_screen.dart';

class JobBookingFirstScreen extends StatefulWidget {
  const JobBookingFirstScreen({super.key});

  @override
  State<JobBookingFirstScreen> createState() => _JobBookingFirstScreenState();
}

class _JobBookingFirstScreenState extends State<JobBookingFirstScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<ServiceModel> _selectedServices = [];

  @override
  void initState() {
    // Initialize job booking cubit when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobBookingCubit>().initializeJob();
    });
    super.initState();
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      context.read<ServiceCubit>().searchServices(keyword: query);
    } else {
      context.read<ServiceCubit>().clearSearch();
    }
  }

  void _addService(ServiceModel service) {
    // Use JobBookingCubit to add service instead of local state
    context.read<JobBookingCubit>().addService(service.id);

    // Clear search and hide keyboard
    _searchController.clear();
    _searchFocusNode.unfocus();
    context.read<ServiceCubit>().clearSearch();
  }

  void _removeService(String serviceId) {
    // Use JobBookingCubit to remove service instead of local state
    context.read<JobBookingCubit>().removeService(serviceId);
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: AppTypography.fontSize16Bold.copyWith(
            color: Colors.black,
            backgroundColor: Colors.yellow,
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: AppTypography.fontSize16Bold.copyWith(color: Colors.black),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildHighlightedCategory(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: AppTypography.fontSize12.copyWith(color: Colors.blue),
      );
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: AppTypography.fontSize12.copyWith(color: Colors.blue),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: AppTypography.fontSize12.copyWith(
            color: Colors.blue,
            backgroundColor: Colors.yellow,
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: AppTypography.fontSize12.copyWith(color: Colors.blue),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<JobBookingCubit, JobBookingState>(
          listener: (context, state) {
            // TODO: implement listener
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top colored bar
                    Container(
                      height: 12.h,
                      width: MediaQuery.of(context).size.width * .071,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 1,
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Close button
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: Color(0xFF71788F),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Express Job badge
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Express Job',
                          style: AppTypography.fontSize12.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Header Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Service Pricing',
                                style: AppTypography.fontSize38.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _buildInfoDialog(),
                                  );
                                },
                                child: Icon(
                                  Icons.help_outline,
                                  color: Colors.grey.shade500,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'List your service & book a job',
                            style: AppTypography.fontSize14.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16.w),
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: _selectedServices.isEmpty
                                      ? 'Search services...'
                                      : 'iPhone 16 lcd repair...',
                                  hintStyle: AppTypography.fontSize14.copyWith(
                                    color: Colors.grey.shade400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  context.read<ServiceCubit>().clearSearch();
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16.w),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade400,
                                    size: 20.sp,
                                  ),
                                ),
                              )
                            else
                              SizedBox(width: 16.w),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Results from API
              BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (state is ServiceLoaded) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final service = state.servicesResponse.services[index];

                        // Check if service is selected using JobBookingCubit
                        return BlocBuilder<JobBookingCubit, JobBookingState>(
                          builder: (context, bookingState) {
                            final isAlreadySelected =
                                bookingState is JobBookingData
                                ? bookingState.job.servicesIds.contains(
                                    service.id,
                                  )
                                : false;

                            return GestureDetector(
                              onTap: () => _addService(service),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildHighlightedText(
                                              service.name,
                                              state.searchQuery,
                                            ),
                                            SizedBox(height: 4.h),
                                            _buildHighlightedCategory(
                                              service.category,
                                              state.searchQuery,
                                            ),
                                            if (service
                                                .description
                                                .isNotEmpty) ...[
                                              SizedBox(height: 4.h),
                                              Text(
                                                service.description,
                                                style: AppTypography.fontSize12
                                                    .copyWith(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${service.priceInclVat.toStringAsFixed(2)} €',
                                            style: AppTypography.fontSize16Bold
                                                .copyWith(
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'incl. ${service.vat}% VAT',
                                            style: AppTypography.fontSize10
                                                .copyWith(
                                                  color: Colors.grey.shade500,
                                                ),
                                          ),
                                        ],
                                      ),
                                      if (isAlreadySelected) ...[
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20.sp,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }, childCount: state.servicesResponse.services.length),
                    );
                  }

                  if (state is ServiceNoResults) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'No services found for "${state.searchQuery}"',
                            style: AppTypography.fontSize14.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is ServiceError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Error: ${state.message}',
                                style: AppTypography.fontSize14.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ServiceCubit>()
                                    .refreshSearch(),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Selected Services from JobBookingCubit
              BlocBuilder<JobBookingCubit, JobBookingState>(
                builder: (context, state) {
                  if (state is JobBookingData &&
                      state.job.servicesIds.isNotEmpty &&
                      _searchController.text.isEmpty) {
                    // In a real app, you'd want to fetch service details for the selected IDs
                    // For now, we'll just show the IDs. You can enhance this by storing service details in JobBookingCubit
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final serviceId = state.job.servicesIds[index];
                        // You might want to store service details in JobBookingCubit for display
                        // For now, we'll just show the ID
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Service ID: $serviceId',
                                      style: AppTypography.fontSize16Bold
                                          .copyWith(color: Colors.black),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Tap to see details',
                                      style: AppTypography.fontSize12.copyWith(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Price TBD', // You can store price in JobBookingCubit
                                    style: AppTypography.fontSize16Bold
                                        .copyWith(color: AppColors.primary),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'incl. VAT',
                                    style: AppTypography.fontSize10.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () => _removeService(serviceId),
                                child: Container(
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: state.job.servicesIds.length),
                    );
                  }

                  // Empty state when no search and no selected services
                  if (_searchController.text.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 48.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Search for services',
                              style: AppTypography.fontSize16.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Type in the search bar to find services',
                              style: AppTypography.fontSize12.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),

        // Bottom Button - Show only when services are selected
        bottomNavigationBar: BlocBuilder<JobBookingCubit, JobBookingState>(
          builder: (context, state) {
            final hasServices =
                state is JobBookingData && state.job.servicesIds.isNotEmpty;

            if (hasServices && _searchController.text.isEmpty) {
              return _buildBookingButton(state);
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.question_mark_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'To book a job you must add at least one service to your service list.',
                    style: AppTypography.fontSize14.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Use your desktop computer at\nhttps://my.repairmc.com/service',
              style: AppTypography.fontSize12.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                ),
                child: Text(
                  'Dismiss',
                  style: AppTypography.fontSize14.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton(JobBookingData bookingData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 2,
          left: 12.w,
          right: 12.w,
          top: 2,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${bookingData.job.servicesIds.length} x Service selected',
                style: AppTypography.fontSize14.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Pass the JobBookingCubit data to next screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => JobBookingStartBookingJobScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                  child: Text(
                    'Start booking',
                    style: AppTypography.fontSize16Bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
