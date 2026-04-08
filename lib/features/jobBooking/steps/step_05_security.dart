import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/five/widgets/pattern_input_widget.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 5 – Device Security (None / Password / Pattern)
class StepSecurityWidget extends StatefulWidget {
  const StepSecurityWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepSecurityWidget> createState() => StepSecurityWidgetState();
}

class StepSecurityWidgetState extends State<StepSecurityWidget> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  String selectedOption = 'none';
  List<int> connectedDots = [];

  @override
  void initState() {
    super.initState();
    // Default "none" is always valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        setState(() {
          selectedOption = bookingState.device.deviceSecurity;
        });
        _updateDeviceSecurityInCubit();
      } else {
        widget.onCanProceedChanged(true);
      }
    });
  }

  void _updateDeviceSecurityInCubit() {
    String securityType = selectedOption;
    switch (selectedOption) {
      case 'password':
        if (_passwordController.text.isEmpty) securityType = 'none';
        break;
      case 'pattern':
        if (connectedDots.isEmpty) securityType = 'none';
        break;
      default:
        securityType = 'none';
    }
    context.read<JobBookingCubit>().updateDeviceInfo(
      deviceSecurity: securityType,
    );

    // Update can-proceed
    bool canProceed = true;
    if (selectedOption == 'password' && _passwordController.text.isEmpty) {
      canProceed = false;
    } else if (selectedOption == 'pattern' && connectedDots.isEmpty) {
      canProceed = false;
    }
    widget.onCanProceedChanged(canProceed);
  }

  bool _validateAndSave() {
    _updateDeviceSecurityInCubit();
    if (selectedOption == 'password' && _passwordController.text.isEmpty) {
      SnackbarDemo(
        message: 'Please enter the password or select "No Security".',
      ).showCustomSnackbar(context);
      return false;
    }
    if (selectedOption == 'pattern' && connectedDots.isEmpty) {
      SnackbarDemo(
        message: 'Please draw a pattern or select "No Security".',
      ).showCustomSnackbar(context);
      return false;
    }
    return true;
  }

  void _showPatternBottomSheet() async {
    final List<int>? result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PatternBottomSheet(initialPattern: connectedDots),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        selectedOption = result.isNotEmpty ? 'pattern' : 'none';
        connectedDots = result;
      });
      _updateDeviceSecurityInCubit();
    }
  }

  /// Called by wizard before advancing – returns true if step is valid
  bool validate() => _validateAndSave();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                TitleWidget(
                  stepNumber: 5,
                  title: 'Device Security',
                  subTitle: 'Select the security type',
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                _buildSecurityOption(
                  icon: Icons.security,
                  title: 'No Security',
                  subtitle: 'Device has no security lock',
                  isSelected: selectedOption == 'none',
                  onTap: () {
                    FocusScope.of(context).unfocus(); // Hide keyboard
                    setState(() => selectedOption = 'none');
                    _passwordController.clear();
                    connectedDots.clear();
                    _updateDeviceSecurityInCubit();
                  },
                ),
                SizedBox(height: 12.h),
                _buildSecurityOption(
                  icon: Icons.lock_outline,
                  title: 'Password / PIN',
                  subtitle: 'Device protected with a password or PIN',
                  isSelected: selectedOption == 'password',
                  onTap: () {
                    setState(() => selectedOption = 'password');
                    connectedDots.clear();
                    _updateDeviceSecurityInCubit();
                    // Focus the text field automatically when selected
                    Future.delayed(Duration.zero, () {
                      if (mounted) {
                        _passwordFocusNode.requestFocus();
                      }
                    });
                  },
                ),
                SizedBox(height: 12.h),
                _buildSecurityOption(
                  icon: Icons.pattern,
                  title: 'Security Pattern',
                  subtitle: 'Device protected with a pattern',
                  isSelected: selectedOption == 'pattern',
                  onTap: () {
                    FocusScope.of(context).unfocus(); // Hide keyboard
                    setState(() => selectedOption = 'pattern');
                    _passwordController.clear();
                    _showPatternBottomSheet();
                  },
                ),
              ],
            ),
          ),
        ),

        if (selectedOption == 'password')
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Device Password / PIN',
                      style: AppTypography.fontSize14.copyWith(
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      cursorColor: AppColors.warningColor,
                      onChanged: (_) => _updateDeviceSecurityInCubit(),
                      decoration: InputDecoration(
                        hintText: 'Enter password or PIN...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: AppTypography.fontSize16,
                    ),
                  ],
                ),
              ),
            ),
          ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: BlocBuilder<JobBookingCubit, JobBookingState>(
              builder: (context, state) {
                final deviceSecurity = state is JobBookingData
                    ? state.device.deviceSecurity
                    : 'none';
                String securityText;
                switch (deviceSecurity) {
                  case 'password':
                    securityText = 'Password/PIN Protected';
                    break;
                  case 'pattern':
                    securityText = 'Pattern Protected';
                    break;
                  default:
                    securityText = 'No Security';
                }
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Security Status: $securityText',
                        style: AppTypography.fontSize12.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
      ],
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.fontSize16.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade800,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTypography.fontSize12.copyWith(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.8)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}

// Pattern bottom sheet – reused from original screen
class _PatternBottomSheet extends StatefulWidget {
  final List<int> initialPattern;
  const _PatternBottomSheet({required this.initialPattern});

  @override
  _PatternBottomSheetState createState() => _PatternBottomSheetState();
}

class _PatternBottomSheetState extends State<_PatternBottomSheet> {
  List<int> connectedDots = [];

  @override
  void initState() {
    super.initState();
    connectedDots = List.from(widget.initialPattern);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Draw Security Pattern',
            style: AppTypography.fontSize16Bold.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          PatternInputWidget(
            initialPattern: connectedDots,
            onPatternChanged: (pattern) =>
                setState(() => connectedDots = pattern),
          ),
          SizedBox(height: 16.h),
          if (connectedDots.isNotEmpty)
            Text(
              'Pattern: ${connectedDots.map((d) => d + 1).join(' → ')}',
              style: AppTypography.fontSize14.copyWith(
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  onPressed: () => setState(() => connectedDots.clear()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm'),
                  onPressed: connectedDots.isNotEmpty
                      ? () => Navigator.of(context).pop(connectedDots)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
