import 'package:intl/intl.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/dashboard/cubits/dashboard_cubit.dart';
import 'package:repair_cms/features/quickTask/cubit/quick_task_cubit.dart';
import 'package:repair_cms/features/quickTask/screens/quick_task_screen.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:math' as math;
import 'widgets/enhanced_search_widget.dart';
import 'widgets/job_progress_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xFFDB00FF), Color(0xFF432BFF)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    print(context.read<SignInCubit>().userType);
    print(context.read<SignInCubit>().userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllDashboardData();
      context.read<QuickTaskCubit>().getTodos();
    });

    // Initialize cubit

    super.initState();
  }

  void _loadAllDashboardData() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      context.read<DashboardCubit>().loadAllDashboardData(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        userId: storage.read('userId'),
      );
    } else {
      context.read<DashboardCubit>().getThisMonthStats(storage.read('userId'));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Function to show date range picker bottom sheet
  void _showDateRangePicker() {
    DateTime? tempStartDate = _selectedStartDate;
    DateTime? tempEndDate = _selectedEndDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select date Range', style: AppTypography.fontSize20.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Selected Date Range Display
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tempStartDate != null && tempEndDate != null
                          ? '${DateFormat('dd.MM.yyyy').format(tempStartDate!)} - ${DateFormat('dd.MM.yyyy').format(tempEndDate!)}'
                          : 'Select start and end dates',
                      style: AppTypography.fontSize16.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Date Range Picker
              Expanded(
                child: SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: tempStartDate != null && tempEndDate != null
                      ? PickerDateRange(tempStartDate, tempEndDate)
                      : null,
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is PickerDateRange) {
                      setModalState(() {
                        tempStartDate = args.value.startDate;
                        tempEndDate = args.value.endDate;
                      });
                    }
                  },
                  monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
                  selectionColor: AppColors.primary,
                  startRangeSelectionColor: AppColors.primary,
                  endRangeSelectionColor: AppColors.primary,
                  rangeSelectionColor: AppColors.primary.withValues(alpha: 0.2),
                  todayHighlightColor: AppColors.primary,
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              Row(
                children: [
                  // Clear Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          tempStartDate = null;
                          tempEndDate = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Clear', style: AppTypography.fontSize16.copyWith(color: AppColors.primary)),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Apply Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: tempStartDate != null && tempEndDate != null
                          ? () {
                              // Update the main state with selected dates
                              setState(() {
                                _selectedStartDate = tempStartDate;
                                _selectedEndDate = tempEndDate;
                              });
                              Navigator.pop(context);

                              // Reload dashboard data with new date range
                              context.read<DashboardCubit>().getDashboardStats(
                                startDate: _selectedStartDate,
                                endDate: _selectedEndDate,
                                userId: storage.read('userId'),
                              );

                              // Show success message
                              showCustomToast('Date range applied successfully', isError: false);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Apply', style: AppTypography.fontSize16.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (context) => context.read<DashboardCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 28.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          // Greeting Section
                          _buildGreetingSection(),
                          SizedBox(height: 12.h),

                          // Incomplete To-Do's Card
                          _buildIncompleteToDoCard(context),
                          SizedBox(height: 12.h),

                          // Completed Jobs Card
                          _buildCompletedJobsCard(),
                          SizedBox(height: 16.h),

                          // Job Progress Card - Using the new widget
                          const JobProgressWidget(),

                          // Add bottom padding for FAB
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Enhanced Search Widget positioned at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: EnhancedSearchWidget(
                  onSearchChanged: (query) {
                    // Handle search query changes
                    print('Search query: $query');
                  },
                  onQRScanPressed: () {
                    // Handle QR scan button press
                    _showQRScanDialog();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Good Morning, John',
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: AppTypography.fontSize22.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 8.w),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Text('👋', style: TextStyle(fontSize: 24.sp)),
            ),
          ],
        ),
        Text(
          DateFormat('dd.MMM.yyyy').format(DateTime.now()),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: AppTypography.fontSize14.copyWith(color: AppColors.lightFontColor),
        ),
      ],
    );
  }

  Widget _buildIncompleteToDoCard(BuildContext context) {
    return BlocBuilder<QuickTaskCubit, QuickTaskState>(
      builder: (context, state) {
        final incompleteCount = context.read<QuickTaskCubit>().getIncompleteTodosCount();

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => QuickTaskScreen()));
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Incomplete To-Do\'s',
                        style: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor),
                      ),
                      SizedBox(height: 8.h),
                      Text('$incompleteCount', style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.today_rounded, color: AppColors.primary, size: 22.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'See All To-Do\'s',
                        style: AppTypography.fontSize16.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedJobsCard() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        int completedJobs = 0;
        String dateRangeText = '01.02.2024 - 28.02.2024';

        if (state is DashboardLoaded) {
          completedJobs = state.dashboardStats!.completedJobs;

          // Format the date range from the API response
          final filterRange = state.dashboardStats!.filterRange;
          if (filterRange.startDate.isNotEmpty && filterRange.endDate.isNotEmpty) {
            try {
              final startDate = DateTime.parse(filterRange.startDate);
              final endDate = DateTime.parse(filterRange.endDate);
              dateRangeText =
                  '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}';
            } catch (e) {
              debugPrint('Error parsing dates: $e');
            }
          }
        } else if (_selectedStartDate != null && _selectedEndDate != null) {
          dateRangeText =
              '${DateFormat('dd.MM.yyyy').format(_selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(_selectedEndDate!)}';
        }

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(color: const Color(0xFFC507FF), borderRadius: BorderRadius.circular(8.r)),
                    child: Icon(SolarIconsBold.caseMinimalistic, color: Colors.white, size: 30.sp),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(8.r)),
                    child: GestureDetector(
                      onTap: _showDateRangePicker,
                      child: Row(
                        children: [
                          Text(
                            _selectedStartDate != null && _selectedEndDate != null
                                ? '${DateFormat('dd.MM.yyyy').format(_selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(_selectedEndDate!)}'
                                : 'This Month',
                            style: AppTypography.fontSize16,
                          ),
                          SizedBox(width: 2.w),
                          Container(height: 28.h, color: const Color(0x898FA0B2), width: 2.w),
                          SizedBox(width: 2.w),
                          const Icon(Icons.calendar_month, color: Color(0xFF2589F6)),
                          Icon(Icons.keyboard_arrow_down, color: const Color(0xFF2589F6), size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateRangeText, style: AppTypography.fontSize14.copyWith(color: AppColors.fontMainColor)),
                      Text(
                        'Completed Jobs',
                        style: AppTypography.fontSize24.copyWith(
                          fontWeight: FontWeight.w500,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ],
                  ),
                  Text(completedJobs.toString(), style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),

              // Loading state
              if (state is DashboardLoading) ...[
                SizedBox(height: 12.h),
                LinearProgressIndicator(
                  backgroundColor: AppColors.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],

              // Error state
              if (state is DashboardError) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text('Failed to load data', style: AppTypography.fontSize12.copyWith(color: Colors.red)),
                      ),
                      GestureDetector(
                        onTap: _loadAllDashboardData,
                        child: Text(
                          'Retry',
                          style: AppTypography.fontSize12.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showQRScanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Scanner'),
          content: const Text('QR Scanner functionality would be implemented here.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
        );
      },
    );
  }
}
