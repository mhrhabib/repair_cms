import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/thirteen/job_booking_customer_signature_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingPhysicalLocationScreen extends StatefulWidget {
  final String jobId;
  const JobBookingPhysicalLocationScreen({super.key, required this.jobId});

  @override
  State<JobBookingPhysicalLocationScreen> createState() =>
      _JobBookingPhysicalLocationScreenState();
}

class _JobBookingPhysicalLocationScreenState
    extends State<JobBookingPhysicalLocationScreen> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate with example location
    _locationController.text = '';
  }

  void _saveAndNavigate() {
    if (_locationController.text.isNotEmpty) {
      // Save to cubit
      context.read<JobBookingCubit>().updatePhysicalLocation(
        _locationController.text.trim(),
      );

      // Navigate to next screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              JobBookingCustomerSignatureScreen(jobId: widget.jobId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else {
      showCustomToast('Please specify a storage location', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              height: 12.h,
              width: MediaQuery.of(context).size.width * .071 * 13,
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
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(
                      context,
                    ).popUntil(ModalRoute.withName(RouteNames.home)),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Step indicator
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title and subtitle
            const Text(
              'Physical Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '(Storage during service)',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location input field
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Enter storage location',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Helper text
                    Text(
                      'Specify where the device will be stored during repair service (e.g., Shelf 12D, Room A, Locker 5)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                    const Spacer(),

                    // Navigation buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: BottomButtonsGroup(
                        onPressed: _saveAndNavigate,
                        okButtonText: 'Continue',
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
