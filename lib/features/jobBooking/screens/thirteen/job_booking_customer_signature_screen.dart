import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/screens/fourteen/job_booking_select_printer_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingCustomerSignatureScreen extends StatefulWidget {
  const JobBookingCustomerSignatureScreen({super.key});

  @override
  State<JobBookingCustomerSignatureScreen> createState() => _JobBookingCustomerSignatureScreenState();
}

class _JobBookingCustomerSignatureScreenState extends State<JobBookingCustomerSignatureScreen> {
  bool _hasSignature = false;
  final List<List<Offset>> _signaturePaths = [];
  final List<Offset> _currentPath = [];

  void _resetSignature() {
    setState(() {
      _hasSignature = false;
      _signaturePaths.clear();
      _currentPath.clear();
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPath.clear();
      _currentPath.add(details.localPosition);
      _hasSignature = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPath.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_currentPath.isNotEmpty) {
        _signaturePaths.add(List.from(_currentPath));
        _currentPath.clear();
      }
    });
  }

  void _saveSignatureAndNavigate() {
    if (_hasSignature) {
      // Convert signature to data (you might want to encode it as base64 or similar)
      final signatureData = _encodeSignatureData();
      context.read<JobBookingCubit>().updateCustomerSignature(signatureData);

      // Navigate to next screen
      Navigator.push(context, MaterialPageRoute(builder: (context) => const JobBookingSelectPrinterScreen()));
    }
  }

  String _encodeSignatureData() {
    // Convert signature paths to a string representation
    // In a real app, you might want to convert this to base64 or save as image
    return _signaturePaths.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 12.h,
              width: MediaQuery.of(context).size.width * .071 * 13,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

                    // Step indicator
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 42.w,
                        height: 42.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('13', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Title
                    Text('Customer Signature', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                    SizedBox(height: 32.h),

                    // Signature pad container
                    Container(
                      width: double.infinity,
                      height: 280.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColors.whiteColor,
                      ),
                      child: Stack(
                        children: [
                          // Signature pad area
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: CustomPaint(
                                painter: SignaturePainter(signaturePaths: _signaturePaths, currentPath: _currentPath),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Center(
                                    child: Text(
                                      'SIGN HERE',
                                      style: AppTypography.fontSize16.copyWith(
                                        color: _hasSignature ? Colors.transparent : Colors.grey.shade300,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Reset button
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: GestureDetector(
                              onTap: _resetSignature,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh, color: Colors.white, size: 16.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Reset',
                                      style: AppTypography.fontSize10.copyWith(
                                        color: Colors.white,
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

                    SizedBox(height: 16.h),

                    // Helper text
                    Text(
                      'Please sign above to confirm service agreement and device condition acknowledgment',
                      style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Navigation buttons
                    BottomButtonsGroup(onPressed: _hasSignature ? _saveSignatureAndNavigate : null),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> signaturePaths;
  final List<Offset> currentPath;

  SignaturePainter({required this.signaturePaths, required this.currentPath});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed paths
    for (final path in signaturePaths) {
      if (path.isNotEmpty) {
        final pathToDraw = Path();
        pathToDraw.moveTo(path.first.dx, path.first.dy);

        for (int i = 1; i < path.length; i++) {
          pathToDraw.lineTo(path[i].dx, path[i].dy);
        }

        canvas.drawPath(pathToDraw, paint);
      }
    }

    // Draw current path being drawn
    if (currentPath.isNotEmpty) {
      final pathToDraw = Path();
      pathToDraw.moveTo(currentPath.first.dx, currentPath.first.dy);

      for (int i = 1; i < currentPath.length; i++) {
        pathToDraw.lineTo(currentPath[i].dx, currentPath[i].dy);
      }

      canvas.drawPath(pathToDraw, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
