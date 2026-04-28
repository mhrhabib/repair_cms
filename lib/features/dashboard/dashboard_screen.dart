// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/core/helpers/storage.dart';
import 'package:repair_cms/features/auth/signin/cubit/sign_in_cubit.dart';
import 'package:repair_cms/features/company/cubits/company_cubit.dart';
import 'package:repair_cms/features/dashboard/cubits/dashboard_cubit.dart';
import 'package:repair_cms/features/jobReceipt/cubits/job_receipt_cubit.dart';
import 'package:repair_cms/features/notifications/notifications_screen.dart';
import 'package:repair_cms/features/profile/cubit/profile_cubit.dart';
import 'package:repair_cms/features/profile/profile_options_screen.dart';
import 'package:repair_cms/features/quickTask/cubit/quick_task_cubit.dart';
import 'package:repair_cms/features/quickTask/screens/quick_task_screen.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:math' as math;
import 'package:repair_cms/features/myJobs/cubits/job_cubit.dart';
import 'widgets/job_progress_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xFFDB00FF), Color(0xFF432BFF)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _lastAvatarUrl;
  ImageProvider? _avatarImageProvider;
  String? _avatarImageKey;

  @override
  void initState() {
    super.initState();
    // Do not restore a cached signed URL from storage — S3 signatures expire
    // (default ~66h). Using a stale one causes 403s. Always fetch fresh via
    // ProfileCubit.getImageUrl when the profile loads.
    try {
      debugPrint('🚀 [DashboardScreen] Initializing dashboard');
      debugPrint('👤 [DashboardScreen] User Type: ${context.read<SignInCubit>().userType}');
      debugPrint('👤 [DashboardScreen] User ID: ${context.read<SignInCubit>().userId}');

      // Add observer to detect when app comes to foreground
      WidgetsBinding.instance.addObserver(this);

      // Schedule data loading after first frame to prevent ANR
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Load dashboard data with timeout protection
          _loadAllDashboardData();
          // Load quick tasks
          context.read<QuickTaskCubit>().getTodos();
          // Fetch company and receipt data
          _fetchAndStoreCompanyAndReceiptData();
          // Load user profile to ensure profile image is updated
          context.read<ProfileCubit>().getUserProfile();
        }
      });
    } catch (e) {
      debugPrint('❌ [DashboardScreen] Error in initState: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh dashboard when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 [DashboardScreen] App resumed - refreshing dashboard data');
      _loadAllDashboardData();
      context.read<QuickTaskCubit>().getTodos();
      context.read<ProfileCubit>().getUserProfile();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're coming back from another route
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && route.settings.name == null) {
      // This runs when navigating back to this screen
      Future.microtask(() {
        debugPrint('🔄 [DashboardScreen] Returned to dashboard - refreshing data');
        _loadAllDashboardData();
        context.read<QuickTaskCubit>().getTodos();
        context.read<ProfileCubit>().getUserProfile();
      });
    }
  }

  void _fetchAndStoreCompanyAndReceiptData() {
    try {
      final userId = storage.read('userId');
      final companyId = storage.read('companyId');

      debugPrint('🚀 [DashboardScreen] Fetching company and receipt data');
      debugPrint('👤 [DashboardScreen] User ID: $userId');
      debugPrint('🏢 [DashboardScreen] Company ID: $companyId');

      // Fetch company info if companyId exists
      if (companyId != null && companyId.toString().isNotEmpty) {
        debugPrint('📦 [DashboardScreen] Fetching company info for ID: $companyId');
        context.read<CompanyCubit>().getCompanyInfo(companyId: companyId.toString());
      } else {
        debugPrint('⚠️ [DashboardScreen] No companyId found in storage');
      }

      // Fetch job receipt if userId exists
      if (userId != null && userId.toString().isNotEmpty) {
        debugPrint('📋 [DashboardScreen] Fetching job receipt for user: $userId');
        context.read<JobReceiptCubit>().getJobReceipt(userId: userId.toString());
      } else {
        debugPrint('⚠️ [DashboardScreen] No userId found in storage');
      }
    } catch (e) {
      debugPrint('❌ [DashboardScreen] Error fetching company/receipt data: $e');
    }
  }

  void _loadAllDashboardData({bool force = false}) {
    final userId = storage.read('userId');
    if (_selectedStartDate != null && _selectedEndDate != null) {
      context.read<DashboardCubit>().loadAllDashboardData(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        userId: userId,
        force: force,
      );
    } else {
      // Default to this month but handle forcing
      if (force) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        context.read<DashboardCubit>().loadAllDashboardData(
          startDate: startOfMonth,
          endDate: endOfMonth,
          userId: userId,
          force: true,
        );
      } else {
        context.read<DashboardCubit>().getThisMonthStats(userId);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Function to show date range picker bottom sheet
  void _showDateRangePicker() {
    DateTime? tempStartDate = _selectedStartDate;
    DateTime? tempEndDate = _selectedEndDate;
    final DateRangePickerController pickerController = DateRangePickerController();
    DateTime displayedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: EdgeInsets.all(20.w),
          decoration: ShapeDecoration(
            color: AppColors.whiteColor,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.only(
                topLeft: SmoothRadius(cornerRadius: 30.r, cornerSmoothing: 1.0),
                topRight: SmoothRadius(cornerRadius: 30.r, cornerSmoothing: 1.0),
              ),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select date range',
                    style: AppTypography.sfProHeadLineTextStyle22.copyWith(color: const Color(0xFF1E2D4D)),
                  ),
                  CustomNavButton(onPressed: () => Navigator.pop(context), icon: Icons.close),
                ],
              ),
              SizedBox(height: 16.h),

              // Selected Date Range Display
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: ShapeDecoration(
                  color: AppColors.borderColor.withValues(alpha: 0.3),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 28.r, cornerSmoothing: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(SolarIconsOutline.calendar, size: 20.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      tempStartDate != null && tempEndDate != null
                          ? '${DateFormat('dd MMM, yyyy').format(tempStartDate!)} - ${DateFormat('dd MMM, yyyy').format(tempEndDate!)}'
                          : 'Select dates',
                      style: AppTypography.fontSize16.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E2D4D),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Date Range Picker
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: ShapeDecoration(
                    color: AppColors.borderColor.withValues(alpha: 0.15),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(cornerRadius: 28.r, cornerSmoothing: 1.0),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Custom header: month/year + arrow down + nav arrows
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                pickerController.view = DateRangePickerView.year;
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy').format(displayedDate),
                                    style: AppTypography.fontSize16.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.lightFontColor,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20.sp,
                                    color: AppColors.lightFontColor,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                pickerController.backward!();
                              },
                              child: Icon(
                                Icons.chevron_left,
                                size: 24.sp,
                                color: AppColors.lightFontColor,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () {
                                pickerController.forward!();
                              },
                              child: Icon(
                                Icons.chevron_right,
                                size: 24.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SfDateRangePicker(
                          controller: pickerController,
                          backgroundColor: Colors.transparent,
                          headerHeight: 0,
                          selectionMode: DateRangePickerSelectionMode.range,
                          initialSelectedRange: tempStartDate != null && tempEndDate != null
                              ? PickerDateRange(tempStartDate, tempEndDate)
                              : null,
                          onViewChanged: (DateRangePickerViewChangedArgs args) {
                            final visibleRange = args.visibleDateRange;
                            if (visibleRange.startDate != null && visibleRange.endDate != null) {
                              final midTime =
                                  (visibleRange.startDate!.millisecondsSinceEpoch +
                                      visibleRange.endDate!.millisecondsSinceEpoch) ~/
                                  2;
                              final midDate = DateTime.fromMillisecondsSinceEpoch(midTime);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setModalState(() {
                                  displayedDate = midDate;
                                });
                              });
                            }
                          },
                          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                            if (args.value is PickerDateRange) {
                              setModalState(() {
                                tempStartDate = args.value.startDate;
                                tempEndDate = args.value.endDate;
                              });
                            }
                          },
                          monthViewSettings: const DateRangePickerMonthViewSettings(
                            enableSwipeSelection: false,
                            firstDayOfWeek: 1,
                          ),
                          selectionColor: AppColors.primary,
                          startRangeSelectionColor: AppColors.primary,
                          endRangeSelectionColor: AppColors.primary,
                          rangeSelectionColor: AppColors.primary.withValues(alpha: 0.2),
                          todayHighlightColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              Row(
                children: [
                  // Clear Button
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(28.r),
                      onPressed: () {
                        setModalState(() {
                          tempStartDate = null;
                          tempEndDate = null;
                        });
                      },
                      child: Text(
                        'Clear',
                        style: AppTypography.fontSize16.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Apply Button
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28.r),
                      onPressed: tempStartDate != null && tempEndDate != null
                          ? () {
                              // Update the main state with selected dates
                              setState(() {
                                _selectedStartDate = tempStartDate;
                                _selectedEndDate = tempEndDate;
                              });
                              Navigator.pop(context);

                              // Reload dashboard data with new date range
                              context.read<DashboardCubit>().loadAllDashboardData(
                                startDate: _selectedStartDate,
                                endDate: _selectedEndDate,
                                userId: storage.read('userId'),
                              );

                              // Show success message
                              SnackbarDemo(message: 'Date range applied successfully').showCustomSnackbar(context);
                            }
                          : null,
                      child: Text(
                        'Apply',
                        style: AppTypography.fontSize16.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to company cubit and store data
        BlocListener<CompanyCubit, CompanyState>(
          listener: (context, state) {
            if (state is CompanyLoaded) {
              try {
                debugPrint('✅ [DashboardScreen] Company data loaded, storing in GetStorage');
                // Store company data as JSON string
                storage.write('companyData', jsonEncode(state.company.toJson()));
                debugPrint('📦 [DashboardScreen] Company name: ${state.company.name}');
              } catch (e) {
                debugPrint('❌ [DashboardScreen] Error storing company data: $e');
              }
            } else if (state is CompanyError) {
              debugPrint('❌ [DashboardScreen] Company error: ${state.message}');
              // Optionally show a toast notification
              SnackbarDemo(message: 'Failed to load company info').showCustomSnackbar(context);
            }
          },
        ),
        // Listen to job receipt cubit and store data
        BlocListener<JobReceiptCubit, JobReceiptState>(
          listener: (context, state) {
            if (state is JobReceiptLoaded) {
              try {
                debugPrint('✅ [DashboardScreen] Job receipt data loaded, storing in GetStorage');
                // Store receipt data as JSON string
                storage.write('jobReceiptData', jsonEncode(state.receipt.toJson()));
                debugPrint('📦 [DashboardScreen] QR Code Enabled: ${state.receipt.qrCodeEnabled}');
              } catch (e) {
                debugPrint('❌ [DashboardScreen] Error storing receipt data: $e');
              }
            } else if (state is JobReceiptError) {
              debugPrint('❌ [DashboardScreen] Job receipt error: ${state.message}');
              // Optionally show a toast notification
              SnackbarDemo(message: 'Failed to load receipt settings').showCustomSnackbar(context);
            }
          },
        ),
        // Listen to profile cubit and store data
        BlocListener<ProfileCubit, ProfileStates>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              try {
                debugPrint('✅ [DashboardScreen] Profile data loaded, storing in GetStorage');
                storage.write('user', state.user.toJson());
                storage.write('fullName', state.user.fullName);
                // storage.write('userId', state.user.id);
                if (state.user.location != null) {
                  storage.write('locationId', state.user.location!.id);
                }
              } catch (e) {
                debugPrint('❌ [DashboardScreen] Error storing profile data: $e');
              }
            }
          },
        ),
        // 🔄 Listen to JobCubit — refresh dashboard whenever any job status changes
        BlocListener<JobCubit, JobStates>(
          listener: (context, state) {
            if (state is JobStatusUpdated || state is JobStatusUpdateSuccess) {
              debugPrint('🔄 [DashboardScreen] Job status changed — forcing explicit dashboard refresh');
              _loadAllDashboardData(force: true);
              context.read<QuickTaskCubit>().getTodos();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // SizedBox(height: 28.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: 12.h),
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
              // Positioned(
              //   top: 0,
              //   left: 0,
              //   right: 0,
              //   child: EnhancedSearchWidget(
              //     onSearchChanged: (query) {
              //       // Handle search query changes
              //       debugPrint('Search query: $query');
              //     },
              //     onQRScanPressed: () {
              //       // Handle QR scan button press
              //       _showQRScanDialog();
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    // Get actual user name from storage
    final fullName = storage.read('fullName') ?? 'User';
    final firstName = fullName.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LEFT: Greeting — takes remaining space, never overflows
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Hello $firstName',
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: AppTypography.fontSize22.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis, // long names won't overflow
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Text('👋', style: TextStyle(fontSize: 24.sp)),
                  ),
                ],
              ),
            ),

            // RIGHT: Actions — always fixed, always at the end
            Row(
              mainAxisSize: MainAxisSize.min, // only takes what it needs
              children: [
                SizedBox(width: 12.w),

                // Notification bell
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen()));
                      },
                      child: Icon(SolarIconsBold.bell, color: Colors.grey.shade600, size: 24.sp),
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

                // Profile avatar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfileOptionsScreen()));
                  },
                  child: BlocBuilder<ProfileCubit, ProfileStates>(
                    buildWhen: (previous, current) => current is ProfileLoaded,
                    builder: (context, state) {
                      if (state is ProfileLoaded) {
                        final avatarUrl = state.user.avatar;

                        if (avatarUrl != null &&
                            avatarUrl.isNotEmpty &&
                            !avatarUrl.startsWith('http') &&
                            _lastAvatarUrl != avatarUrl) {
                          _lastAvatarUrl = avatarUrl;

                          context
                              .read<ProfileCubit>()
                              .getImageUrl(avatarUrl)
                              .then((signedUrl) {
                                if (mounted && signedUrl.isNotEmpty && _avatarImageKey != signedUrl) {
                                  setState(() {
                                    _avatarImageKey = signedUrl;
                                    _avatarImageProvider = NetworkImage(signedUrl);
                                  });
                                }
                              })
                              .catchError((error) {
                                debugPrint('Failed to fetch avatar signed URL: $error');
                              });
                        } else if (avatarUrl != null && avatarUrl.startsWith('http') && _avatarImageKey != avatarUrl) {
                          _avatarImageKey = avatarUrl;
                          _avatarImageProvider = NetworkImage(avatarUrl);
                        }
                      }

                      return CircleAvatar(
                        radius: 16.r,
                        backgroundImage: _avatarImageProvider,
                        backgroundColor: Colors.grey.shade300,
                        onBackgroundImageError: _avatarImageProvider == null
                            ? null
                            : (exception, stackTrace) {
                                debugPrint('Profile image load error: $exception');
                              },
                        child: _avatarImageProvider == null
                            ? Icon(SolarIconsBold.user, size: 18.sp, color: Colors.grey.shade600)
                            : null,
                      );
                    },
                  ),
                ),
              ],
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
            padding: EdgeInsets.all(12.w),
            decoration: ShapeDecoration(
              color: AppColors.whiteColor,
              shape: SmoothRectangleBorder(borderRadius: SmoothBorderRadius(cornerRadius: 28.r, cornerSmoothing: 1.0)),
              shadows: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Incomplete To-Do\'s',
                          style: AppTypography.fontSize16.copyWith(color: AppColors.lightFontColor),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text('$incompleteCount', style: AppTypography.fontSize28.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: ShapeDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(cornerRadius: 12.r, cornerSmoothing: 1.0),
                          side: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.today_rounded, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'See All To-Do\'s',
                            style: AppTypography.fontSize14.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
        final cubit = context.read<DashboardCubit>();
        int completedJobs = cubit.dashboardStats?.completedJobs ?? 0;
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
        } else if (state is DashboardLoading && cubit.dashboardStats != null) {
          // Use cached data during loading to prevent flickering to 0
          completedJobs = cubit.dashboardStats!.completedJobs;
          final filterRange = cubit.dashboardStats!.filterRange;
          if (filterRange.startDate.isNotEmpty && filterRange.endDate.isNotEmpty) {
            try {
              dateRangeText =
                  '${DateFormat('dd.MM.yyyy').format(DateTime.parse(filterRange.startDate))} - ${DateFormat('dd.MM.yyyy').format(DateTime.parse(filterRange.endDate))}';
            } catch (e) {}
          }
        } else if (_selectedStartDate != null && _selectedEndDate != null) {
          dateRangeText =
              '${DateFormat('dd.MM.yyyy').format(_selectedStartDate!)} - ${DateFormat('dd.MM.yyyy').format(_selectedEndDate!)}';
        }

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: ShapeDecoration(
            color: AppColors.whiteColor,
            shape: SmoothRectangleBorder(borderRadius: SmoothBorderRadius(cornerRadius: 28.r, cornerSmoothing: 1.0)),
            shadows: [
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
                    decoration: ShapeDecoration(
                      color: const Color(0xFFC507FF),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(cornerRadius: 12.r, cornerSmoothing: 1.0),
                      ),
                    ),
                    child: Icon(SolarIconsBold.suitcaseTag, color: Colors.white, size: 30.sp),
                  ),
                  SizedBox(width: 16.w),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: AppColors.borderColor,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(cornerRadius: 12.r, cornerSmoothing: 1.0),
                      ),
                    ),
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
                          Container(height: 25.h, color: const Color(0x898FA0B2), width: 2.w),
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
                CupertinoActivityIndicator(color: AppColors.whiteColor,)
              ],

              // Error state
              if (state is DashboardError) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: ShapeDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(cornerRadius: 8.r, cornerSmoothing: 1.0),
                    ),
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

  // void _showQRScanDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: SmoothRectangleBorder(borderRadius: SmoothBorderRadius(cornerRadius: 16.r, cornerSmoothing: 1.0)),
  //         child: Padding(
  //           padding: EdgeInsets.all(20.w),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text('QR Scanner', style: AppTypography.fontSize20),
  //               SizedBox(height: 16.h),
  //               const Text('QR Scanner functionality would be implemented here.', textAlign: TextAlign.center),
  //               SizedBox(height: 20.h),
  //               TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
