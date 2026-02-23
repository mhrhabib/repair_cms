import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/snakbar_demo.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/five/widgets/pattern_input_widget.dart';
import 'package:repair_cms/features/jobBooking/screens/six/choose_contact_type_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

// Main Screen Widget
class JobBookingDeviceSecurityScreen extends StatefulWidget {
  const JobBookingDeviceSecurityScreen({super.key});

  @override
  State<JobBookingDeviceSecurityScreen> createState() => _JobBookingDeviceSecurityScreenState();
}

class _JobBookingDeviceSecurityScreenState extends State<JobBookingDeviceSecurityScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String selectedOption = 'none'; // Default to "No Security"
  List<int> connectedDots = []; // Stores the confirmed pattern

  @override
  void initState() {
    super.initState();
    // Load existing device security from cubit after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingState = context.read<JobBookingCubit>().state;
      if (bookingState is JobBookingData) {
        final device = bookingState.device;
        final securityType = device.deviceSecurity;
        // final securityValue = device.deviceSecurityValue;

        setState(() {
          selectedOption = securityType;
          if (selectedOption == 'password') {
            // _passwordController.text = securityValue ?? '';
          } else if (selectedOption == 'pattern') {
            // Assuming securityValue for pattern is stored as a string like "1,2,3"
            //connectedDots = securityValue?.split(',').map(int.parse).toList() ?? [];
          }
        });
      }
    });
  }

  // Updates the JobBookingCubit with the selected security information
  void _updateDeviceSecurityInCubit() {
    String securityType = selectedOption;
    String securityValue = '';

    switch (selectedOption) {
      case 'password':
        securityValue = _passwordController.text;
        if (securityValue.isEmpty) securityType = 'none';
        break;
      case 'pattern':
        securityValue = connectedDots.join(','); // Store pattern as a comma-separated string
        if (securityValue.isEmpty) securityType = 'none';
        break;
      case 'none':
      default:
        securityType = 'none';
        securityValue = '';
        break;
    }

    context.read<JobBookingCubit>().updateDeviceInfo(
      deviceSecurity: securityType,
      // deviceSecurityValue: securityValue,
    );
  }

  // Validates the selection and navigates to the next screen
  void _navigateToNextScreen() {
    // Save the final state before navigating
    _updateDeviceSecurityInCubit();

    // Validation check
    if ((selectedOption == 'password' && _passwordController.text.isEmpty) ||
        (selectedOption == 'pattern' && connectedDots.isEmpty)) {
      SnackbarDemo(message: 'Please enter the $selectedOption or select "No Security".').showCustomSnackbar(context);
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ChooseContactTypeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  // Shows the pattern drawing bottom sheet and awaits the result
  void _showPatternBottomSheet() async {
    final List<int>? result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PatternBottomSheet(initialPattern: connectedDots),
    );

    if (!mounted) return;

    // If the user confirmed a pattern (result is not null)
    if (result != null) {
      setState(() {
        selectedOption = result.isNotEmpty ? 'pattern' : 'none';
        connectedDots = result;
      });
      _updateDeviceSecurityInCubit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Progress Bar
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071 * 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 75, 41, 41),
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF71788F),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                        ),
                      ),
                    ),
                    Container(
                      width: 42.w,
                      height: 42.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Text('5', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                    ),
                    SizedBox(height: 12.h),
                    Text('Device Security', style: AppTypography.fontSize22, textAlign: TextAlign.center),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            // Security Options
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
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildSecurityOption(
                      icon: Icons.pattern,
                      title: 'Security Pattern',
                      subtitle: 'Device protected with a pattern',
                      isSelected: selectedOption == 'pattern',
                      onTap: () {
                        setState(() => selectedOption = 'pattern');
                        _passwordController.clear();
                        _showPatternBottomSheet(); // Await result from bottom sheet
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Dynamic Input Field for Password
            if (selectedOption == 'password')
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: _buildPasswordInput(),
                ),
              ),
            // Status Display
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: BlocBuilder<JobBookingCubit, JobBookingState>(
                  builder: (context, state) {
                    final deviceSecurity = state is JobBookingData ? state.device.deviceSecurity : 'none';
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
                        break;
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
                          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16.sp),
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
            SliverFillRemaining(hasScrollBody: false, child: Container()), // Pushes content up
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 8.h : 24.h,
          left: 24.w,
          right: 24.w,
        ),
        child: BottomButtonsGroup(onPressed: _navigateToNextScreen),
      ),
    );
  }

  // Reusable widget for security option buttons
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
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade600, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.fontSize16.copyWith(
                      color: isSelected ? AppColors.primary : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTypography.fontSize12.copyWith(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }

  // Input widget for the password
  Widget _buildPasswordInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Device Password / PIN', style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade800)),
          SizedBox(height: 8.h),
          TextField(
            controller: _passwordController,
            onChanged: (value) => _updateDeviceSecurityInCubit(),
            decoration: InputDecoration(
              hintText: 'Enter password or PIN...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            style: AppTypography.fontSize16,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

// Bottom sheet content widget with its own state
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Draw Security Pattern', style: AppTypography.fontSize16Bold.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 16.h),
          PatternInputWidget(
            initialPattern: connectedDots,
            onPatternChanged: (pattern) {
              setState(() => connectedDots = pattern);
            },
          ),
          SizedBox(height: 16.h),
          if (connectedDots.isNotEmpty)
            Text(
              'Pattern: ${connectedDots.map((dot) => dot + 1).join(' → ')}',
              style: AppTypography.fontSize14.copyWith(color: Colors.green.shade700),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  onPressed: () {
                    setState(() => connectedDots.clear());
                  },
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
                  onPressed: connectedDots.isNotEmpty ? () => Navigator.of(context).pop(connectedDots) : null,
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

// Reusable pattern input widget
