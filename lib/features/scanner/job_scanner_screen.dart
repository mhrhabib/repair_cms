import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';

/// Job Scanner Screen - Scans QR/Barcode for Job IDs
class JobScannerScreen extends StatefulWidget {
  final bool isBarcodeMode;

  const JobScannerScreen({super.key, this.isBarcodeMode = false});

  @override
  State<JobScannerScreen> createState() => _JobScannerScreenState();
}

class _JobScannerScreenState extends State<JobScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;
  bool isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    // Always log the raw capture for debugging
    try {
      debugPrint('🔍 BarcodeCapture received: ${capture.barcodes.map((b) => b.rawValue).toList()}');
      debugPrint('🔎 Barcode formats: ${capture.barcodes.map((b) => b.format).toList()}');
    } catch (e) {
      debugPrint('💥 Error printing capture: $e');
    }

    if (isScanned || isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    // Print each barcode's raw value to console (covers nulls too)
    for (final b in barcodes) {
      debugPrint('📤 Detected barcode rawValue: ${b.rawValue}');
      debugPrint('📤 Detected barcode displayValue: ${b.displayValue}');
      debugPrint('📤 Detected barcode format: ${b.format}');
    }

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) {
      debugPrint('❌ Invalid ${widget.isBarcodeMode ? 'barcode' : 'QR code'} (empty or null)');
      return;
    }

    setState(() {
      isScanned = true;
      isProcessing = true;
    });

    debugPrint('📱 ${widget.isBarcodeMode ? 'Barcode' : 'QR Code'} detected: $code');

    // Stop camera
    await cameraController.stop();

    // Simulate API validation (you can add actual validation here)
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Navigate to Job Details screen with the scanned job ID
    Navigator.pop(context); // Close scanner

    // Show success message with job ID
    // TODO: Navigate to job details screen when route is available
    // Example: context.go('/job-details/$code');
    showCustomToast('Job ID scanned: $code\nNavigate to job details manually');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isBarcodeMode ? 'Barcode Scanner' : 'QR Code Scanner',
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off, color: Colors.white),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Scanner Area
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Instruction Text
                  Text(
                    widget.isBarcodeMode
                        ? 'Align barcode within the frame to scan'
                        : 'Align QR code within the frame to scan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 40.h),

                  // Scanner Widget
                  ScannerWidget(
                    controller: cameraController,
                    onDetect: _onDetect,
                    isProcessing: isProcessing,
                    isBarcodeMode: widget.isBarcodeMode,
                  ),

                  SizedBox(height: 32.h),

                  // Helper Text
                  Text(
                    widget.isBarcodeMode
                        ? 'Scan the barcode on the job document'
                        : 'Scan the QR code on the job document',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                  ),

                  const Spacer(),

                  // Manual Entry Option
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showManualEntryDialog();
                    },
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    label: const Text('Enter Job ID Manually', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // Processing Overlay
            if (isProcessing)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(child: ProcessingLoader(isBarcodeMode: widget.isBarcodeMode)),
              ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Enter Job ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Job ID',
            hintText: 'e.g., JOB12345',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_outline),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final jobId = controller.text.trim();
              if (jobId.isNotEmpty) {
                Navigator.pop(context);
                // TODO: Navigate to job details when route is available
                // Example: context.go('/job-details/$jobId');
                showCustomToast('Job ID entered: $jobId\nNavigate to job details manually');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Go to Job'),
          ),
        ],
      ),
    );
  }
}

// Processing Loader Widget
class ProcessingLoader extends StatelessWidget {
  final bool isBarcodeMode;

  const ProcessingLoader({super.key, this.isBarcodeMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScanningAnimation(),
          SizedBox(height: 24.h),
          Text(
            isBarcodeMode ? 'Processing Barcode...' : 'Processing QR Code...',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.grey[800]),
          ),
          SizedBox(height: 12.h),
          Text(
            'Please wait',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Scanning Animation Widget
class ScanningAnimation extends StatefulWidget {
  const ScanningAnimation({super.key});

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                    gradient: const SweepGradient(colors: [Color(0xFF4CAF50), Colors.transparent], stops: [0.0, 0.5]),
                  ),
                ),
              ),
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 30.sp),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Scanner Widget
class ScannerWidget extends StatelessWidget {
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;
  final bool isProcessing;
  final bool isBarcodeMode;

  const ScannerWidget({
    super.key,
    required this.controller,
    required this.onDetect,
    this.isProcessing = false,
    this.isBarcodeMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            MobileScanner(controller: controller, onDetect: onDetect),
            CustomPaint(
              painter: ScannerOverlayPainter(isProcessing: isProcessing, isBarcodeMode: isBarcodeMode),
              child: const SizedBox.expand(),
            ),
            if (isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: const Color(0xFF4CAF50), size: 60.sp),
                      SizedBox(height: 12.h),
                      Text(
                        isBarcodeMode ? 'Barcode Detected' : 'QR Code Detected',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
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

// Scanner Overlay Painter
class ScannerOverlayPainter extends CustomPainter {
  final bool isProcessing;
  final bool isBarcodeMode;

  ScannerOverlayPainter({this.isProcessing = false, this.isBarcodeMode = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isProcessing ? const Color(0xFF4CAF50) : Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;
    const padding = 40.0;

    // Top-left
    canvas.drawLine(const Offset(padding, padding), const Offset(padding + cornerLength, padding), paint);
    canvas.drawLine(const Offset(padding, padding), const Offset(padding, padding + cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - padding - cornerLength, padding), Offset(size.width - padding, padding), paint);
    canvas.drawLine(Offset(size.width - padding, padding), Offset(size.width - padding, padding + cornerLength), paint);

    // Bottom-left
    canvas.drawLine(
      Offset(padding, size.height - padding - cornerLength),
      Offset(padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(padding + cornerLength, size.height - padding),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - padding, size.height - padding - cornerLength),
      Offset(size.width - padding, size.height - padding),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - padding - cornerLength, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );

    // Scan line
    if (!isProcessing) {
      final scanLinePaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = isBarcodeMode ? 3 : 2;

      if (isBarcodeMode) {
        // Horizontal line for barcode
        canvas.drawLine(
          Offset(padding + 10, size.height / 2),
          Offset(size.width - padding - 10, size.height / 2),
          scanLinePaint,
        );
      } else {
        // Cross pattern for QR code
        canvas.drawLine(
          Offset(padding + 10, size.height / 2),
          Offset(size.width - padding - 10, size.height / 2),
          scanLinePaint,
        );
        canvas.drawLine(
          Offset(size.width / 2, padding + 10),
          Offset(size.width / 2, size.height - padding - 10),
          scanLinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.isProcessing != isProcessing || oldDelegate.isBarcodeMode != isBarcodeMode;
}
