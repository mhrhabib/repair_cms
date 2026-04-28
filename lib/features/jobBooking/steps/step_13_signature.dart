import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/cubits/job/booking/job_booking_cubit.dart';
import 'package:repair_cms/features/jobBooking/widgets/title_widget.dart';

/// Step 13 – Customer Signature
class StepSignatureWidget extends StatefulWidget {
  const StepSignatureWidget({super.key, required this.onCanProceedChanged});

  final void Function(bool canProceed) onCanProceedChanged;

  @override
  State<StepSignatureWidget> createState() => StepSignatureWidgetState();
}

class StepSignatureWidgetState extends State<StepSignatureWidget> {
  bool _hasSignature = false;
  bool _isSaving = false;
  final List<List<Offset>> _signaturePaths = [];
  final List<Offset> _currentPath = [];
  final GlobalKey _signatureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Hide keyboard on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }

      final state = context.read<JobBookingCubit>().state;
      if (state is JobBookingData) {
        if (state.job.signatureFilePath != null &&
            state.job.signatureFilePath!.isNotEmpty) {
          setState(() {
            _hasSignature = true;
          });
          widget.onCanProceedChanged(true);
        }
      }
    });
  }

  void _resetSignature() {
    setState(() {
      _hasSignature = false;
      _signaturePaths.clear();
      _currentPath.clear();
    });
    widget.onCanProceedChanged(false);
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox box =
        _signatureKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    if (localPosition.dx >= 0 &&
        localPosition.dx <= box.size.width &&
        localPosition.dy >= 0 &&
        localPosition.dy <= box.size.height) {
      setState(() {
        _currentPath.clear();
        _currentPath.add(localPosition);
        _hasSignature = true;
      });
      widget.onCanProceedChanged(true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box =
        _signatureKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    if (localPosition.dx >= 0 &&
        localPosition.dx <= box.size.width &&
        localPosition.dy >= 0 &&
        localPosition.dy <= box.size.height) {
      setState(() {
        _currentPath.add(localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_currentPath.isNotEmpty) {
        _signaturePaths.add(List.from(_currentPath));
        _currentPath.clear();
      }
    });
  }

  Future<String> _captureSignatureAsBase64() async {
    try {
      final RenderRepaintBoundary boundary =
          _signatureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      return 'data:image/png;base64,${base64Encode(pngBytes)}';
    } catch (e) {
      throw Exception('Failed to capture signature: $e');
    }
  }

  /// Exposed for wizard navigation
  Future<bool> validate() async {
    if (!_hasSignature || _isSaving) return false;
    setState(() => _isSaving = true);
    try {
      final base64 = await _captureSignatureAsBase64();
      context.read<JobBookingCubit>().updateCustomerSignature(base64);
      setState(() => _isSaving = false);
      return true;
    } catch (e) {
      showCustomToast('Error saving signature: $e', isError: true);
      setState(() => _isSaving = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TitleWidget(
                  stepNumber: 13,
                  title: 'Customer Signature',
                  subTitle: 'Please sign on the pad below',
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                CustomPaint(
                  painter: DashedBorderPainter(
                    color: AppColors.primary,
                    borderRadius: 20.r,
                    dashWidth: 8,
                    dashSpace: 6,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 420.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: DashedBorderPainter(
                            color: AppColors.primary,
                            borderRadius: 20.r,
                            dashWidth: 8,
                            dashSpace: 6,
                          ),

                          child: Padding(
                            padding: EdgeInsets.all(4.r),
                            child: RepaintBoundary(
                              key: _signatureKey,
                              child: GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.white,
                                  child: CustomPaint(
                                    painter: SignaturePainter(
                                      signaturePaths: _signaturePaths,
                                      currentPath: _currentPath,
                                    ),
                                    child: Center(
                                      child: Opacity(
                                        opacity: _hasSignature ? 0 : 0.15,
                                        child: Text(
                                          'SIGN HERE',
                                          style: GoogleFonts.roboto(
                                            color: AppColors.primary,
                                            fontSize: 32.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16.h,
                          right: 16.w,
                          child: InkWell(
                            onTap: _resetSignature,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14.r,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Reset',
                                  style: GoogleFonts.roboto(
                                    color: AppColors.primary,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
        const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
    this.borderRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> signaturePaths;
  final List<Offset> currentPath;
  SignaturePainter({required this.signaturePaths, required this.currentPath});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill entire canvas with white so the captured PNG has no transparent
    // pixels at the corners (prevents anti-aliased corner artifacts in PDF).
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final path in signaturePaths) {
      if (path.length == 1) {
        // Single tap — draw a small dot instead of an empty path
        canvas.drawPoints(ui.PointMode.points, path, paint);
        continue;
      }
      if (path.isNotEmpty) {
        final p = Path()..moveTo(path.first.dx, path.first.dy);
        for (int i = 1; i < path.length; i++) {
          p.lineTo(path[i].dx, path[i].dy);
        }
        canvas.drawPath(p, paint);
      }
    }
    if (currentPath.isNotEmpty) {
      if (currentPath.length == 1) {
        canvas.drawPoints(ui.PointMode.points, currentPath, paint);
      } else {
        final p = Path()..moveTo(currentPath.first.dx, currentPath.first.dy);
        for (int i = 1; i < currentPath.length; i++) {
          p.lineTo(currentPath[i].dx, currentPath[i].dy);
        }
        canvas.drawPath(p, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
