import 'package:flutter/cupertino.dart';
import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:repair_cms/features/moreSettings/labelContent/service/label_content_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_settings_service.dart';
import 'package:repair_cms/features/moreSettings/printerSettings/service/printer_service_factory.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

// ---------------------------------------------------------------------------
// Optional Job data model — pass a real Job object when printing from a job
// detail screen; leave null to show preview with dummy data in settings.
// ---------------------------------------------------------------------------
class LabelJobData {
  final String jobNumber;
  final String customerName;
  final String modelBrand;
  final String date;
  final String jobType;
  final String symptom;
  final String physicalLocation;

  const LabelJobData({
    required this.jobNumber,
    required this.customerName,
    required this.modelBrand,
    required this.date,
    required this.jobType,
    required this.symptom,
    required this.physicalLocation,
  });

  /// Dummy data shown in the settings preview.
  factory LabelJobData.preview() => const LabelJobData(
    jobNumber: 'JOB-12345',
    customerName: 'John Doe',
    modelBrand: 'Apple iPhone 13 Pro',
    date: '05 Jan 2026',
    jobType: 'Screen Repair',
    symptom: 'Cracked screen, battery issue',
    physicalLocation: 'BOX A-12',
  );
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class LabelContentScreen extends StatefulWidget {
  /// Provide real job data when navigating here for a test-print from a job.
  /// Leave null when opening from the Settings menu (preview only).
  final LabelJobData? jobData;

  const LabelContentScreen({super.key, this.jobData});

  @override
  State<LabelContentScreen> createState() => _LabelContentScreenState();
}

class _LabelContentScreenState extends State<LabelContentScreen> {
  final _settingsService = LabelContentSettingsService();
  final _printerSettingsService = PrinterSettingsService();

  // A GlobalKey for the RepaintBoundary that wraps the label.
  // We keep it as a field so the same key is used for both the
  // on-screen preview AND the off-screen capture widget.
  final GlobalKey _labelPreviewKey = GlobalKey();

  // ── Toggle state ──────────────────────────────────────────────────────────
  bool trackingPortalQR = false;
  bool jobQR = true;
  bool barcode = true;
  bool jobNo = true;
  bool customerName = true;
  bool modelBrand = true;
  bool date = true;
  bool jobType = true;
  bool symptom = true;
  bool physicalLocation = true;

  // ── Resolved job data (real or preview dummy) ─────────────────────────────
  late final LabelJobData _jobData;

  @override
  void initState() {
    super.initState();
    _jobData = widget.jobData ?? LabelJobData.preview();
    _loadSettings();
  }

  // ── Settings persistence ──────────────────────────────────────────────────

  void _loadSettings() {
    debugPrint('🏷️ [LabelContentScreen] Loading saved settings');
    final settings = _settingsService.getSettings();
    setState(() {
      trackingPortalQR = settings.showTrackingPortalQR;
      jobQR = settings.showJobQR;
      barcode = settings.showBarcode;
      jobNo = settings.showJobNo;
      customerName = settings.showCustomerName;
      modelBrand = settings.showModelBrand;
      date = settings.showDate;
      jobType = settings.showJobType;
      symptom = settings.showSymptom;
      physicalLocation = settings.showPhysicalLocation;
    });
  }

  Future<void> _saveSettings() async {
    debugPrint('🏷️ [LabelContentScreen] Saving settings');
    final settings = LabelContentSettings(
      showTrackingPortalQR: trackingPortalQR,
      showJobQR: jobQR,
      showBarcode: barcode,
      showJobNo: jobNo,
      showCustomerName: customerName,
      showModelBrand: modelBrand,
      showDate: date,
      showJobType: jobType,
      showSymptom: symptom,
      showPhysicalLocation: physicalLocation,
    );

    try {
      await _settingsService.saveSettings(settings);
      if (mounted) {
        showCustomToast('✅ Label settings saved successfully!', isError: false);
      }
    } catch (e) {
      debugPrint('❌ [LabelContentScreen] Error saving: $e');
      if (mounted) {
        showCustomToast('❌ Failed to save settings', isError: true);
      }
    }
  }

  // ── Test print ────────────────────────────────────────────────────────────

  Future<void> _testPrintLabel() async {
    debugPrint('🖨️ [LabelContentScreen] Starting test print');

    final allPrinters = _printerSettingsService.getAllPrinters();
    final labelPrinters = allPrinters['label'] ?? [];

    if (labelPrinters.isEmpty) {
      showCustomToast('No label printers configured', isError: true);
      debugPrint('❌ [LabelContentScreen] No label printers found');
      return;
    }

    final printer = labelPrinters.firstWhere(
      (p) => p.isDefault,
      orElse: () => labelPrinters.first,
    );

    debugPrint(
      '🖨️ [LabelContentScreen] Using printer: ${printer.printerBrand} ${printer.printerModel}',
    );

    try {
      // ── Step 1: render the label off-screen so barcode/QR are fully drawn ──
      final imageBytes = await _renderLabelToImage();

      if (imageBytes == null) {
        showCustomToast('Failed to generate label image', isError: true);
        return;
      }

      debugPrint(
        '📸 [LabelContentScreen] Label image: ${imageBytes.length} bytes',
      );

      // ── Step 2: send to printer ────────────────────────────────────────────
      final result = await PrinterServiceFactory.printLabelImageWithFallback(
        config: printer,
        imageBytes: imageBytes,
      );

      if (result.success) {
        showCustomToast('✅ Test print sent successfully');
        debugPrint('✅ [LabelContentScreen] ${result.message}');
      } else {
        showCustomToast(result.message, isError: true);
        debugPrint('❌ [LabelContentScreen] ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ [LabelContentScreen] Test print error: $e');
      showCustomToast('Print failed: $e', isError: true);
    }
  }

  // ── Off-screen label render ───────────────────────────────────────────────
  //
  // Why off-screen?
  // BarcodeWidget and QrImageView are vector/canvas-based widgets. When we call
  // boundary.toImage() on the on-screen preview, they may not have completed
  // their first paint (especially if the widget just rebuilt). Rendering the
  // label into its own off-screen pipeline guarantees a full, clean paint
  // before we rasterise.
  //
  // How it works:
  //   1. Build the label widget inside an OffstageWidget so it never appears on
  //      screen but goes through the full Flutter render pipeline.
  //   2. Insert it into the widget tree temporarily via an Overlay entry.
  //   3. Wait for the next frame (post-frame callback) so the widget is fully
  //      laid out and painted.
  //   4. Capture via RepaintBoundary → toImage().
  //   5. Remove the overlay entry.

  Future<Uint8List?> _renderLabelToImage() async {
    debugPrint('📸 [LabelContentScreen] Rendering label off-screen');

    final offscreenKey = GlobalKey();
    Uint8List? result;
    OverlayEntry? entry;

    try {
      final completer = Future<void>(() async {
        // Wait until the overlay entry is inserted and laid out.
        await Future.delayed(Duration.zero);
      });

      entry = OverlayEntry(
        builder: (_) => Offstage(
          // Offstage hides the widget visually but still renders it.
          child: Material(
            color: Colors.transparent,
            child: RepaintBoundary(
              key: offscreenKey,
              child: _buildLabelWidget(
                jobData: _jobData,
                showBarcode: barcode,
                showJobNo: jobNo,
                showJobQR: jobQR,
                showTrackingQR: trackingPortalQR,
                showCustomerName: customerName,
                showModelBrand: modelBrand,
                showDate: date,
                showJobType: jobType,
                showSymptom: symptom,
                showPhysicalLocation: physicalLocation,
              ),
            ),
          ),
        ),
      );

      // Insert into the overlay so Flutter lays it out.
      Overlay.of(context).insert(entry);

      // Wait two frames: one for layout, one for paint.
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          offscreenKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('❌ [LabelContentScreen] Off-screen boundary not found');
        return null;
      }

      // 3.0 pixel ratio gives sharp output for thermal/label printers.
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('❌ [LabelContentScreen] Failed to encode image');
        return null;
      }

      result = byteData.buffer.asUint8List();
      debugPrint(
        '✅ [LabelContentScreen] Off-screen render: ${result.length} bytes',
      );
    } catch (e) {
      debugPrint('❌ [LabelContentScreen] Off-screen render error: $e');
    } finally {
      entry?.remove();
    }

    return result;
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.kBg,
        leading: CustomNavButton(
          onPressed: () => Navigator.pop(context),
          icon: CupertinoIcons.back,
        ),
        middle: Text(
          'Label Content',
          style: AppTypography.sfProHeadLineTextStyle22,
        ),
      ),
      body: Column(
        children: [
          // ── Label preview card ─────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Label Preview',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                // The on-screen preview uses the same builder as the
                // off-screen render so WYSIWYG is guaranteed.
                RepaintBoundary(
                  key: _labelPreviewKey,
                  child: _buildLabelWidget(
                    jobData: _jobData,
                    showBarcode: barcode,
                    showJobNo: jobNo,
                    showJobQR: jobQR,
                    showTrackingQR: trackingPortalQR,
                    showCustomerName: customerName,
                    showModelBrand: modelBrand,
                    showDate: date,
                    showJobType: jobType,
                    showSymptom: symptom,
                    showPhysicalLocation: physicalLocation,
                  ),
                ),
              ],
            ),
          ),

          // ── Toggle list card ───────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Label Details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildToggleItem(
                          'QR-Code (Tracking-Portal)',
                          trackingPortalQR,
                          (value) => setState(() {
                            trackingPortalQR = value;
                            if (value) jobQR = false;
                          }),
                        ),
                        _buildToggleItem(
                          'QR-Code (Job)',
                          jobQR,
                          (value) => setState(() {
                            jobQR = value;
                            if (value) trackingPortalQR = false;
                          }),
                        ),
                        _buildToggleItem(
                          'Barcode',
                          barcode,
                          (value) => setState(() => barcode = value),
                        ),
                        _buildToggleItem(
                          'Job No.',
                          jobNo,
                          (value) => setState(() => jobNo = value),
                        ),
                        _buildToggleItem(
                          'Customer Name / Company Name',
                          customerName,
                          (value) => setState(() => customerName = value),
                        ),
                        _buildToggleItem(
                          'Model, Brand',
                          modelBrand,
                          (value) => setState(() => modelBrand = value),
                        ),
                        _buildToggleItem(
                          'Date',
                          date,
                          (value) => setState(() => date = value),
                        ),
                        _buildToggleItem(
                          'Job type',
                          jobType,
                          (value) => setState(() => jobType = value),
                        ),
                        _buildToggleItem(
                          'Symptom',
                          symptom,
                          (value) => setState(() => symptom = value),
                        ),
                        _buildToggleItem(
                          'Physical location',
                          physicalLocation,
                          (value) => setState(() => physicalLocation = value),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action buttons ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      // ✅ Save first (awaited), then print
                      onPressed: () async {
                        await _saveSettings();
                        await _testPrintLabel();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Test Print',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable label widget ─────────────────────────────────────────────────
  //
  // This is a STATIC-style builder (no widget state dependency) so it can be
  // called identically for:
  //   • The on-screen preview (inside build())
  //   • The off-screen render overlay (inside _renderLabelToImage())
  //
  // Both calls pass the exact same toggle flags and job data, guaranteeing that
  // what the user sees in the preview is exactly what gets printed.

  static Widget _buildLabelWidget({
    required LabelJobData jobData,
    required bool showBarcode,
    required bool showJobNo,
    required bool showJobQR,
    required bool showTrackingQR,
    required bool showCustomerName,
    required bool showModelBrand,
    required bool showDate,
    required bool showJobType,
    required bool showSymptom,
    required bool showPhysicalLocation,
  }) {
    final bool hasQR = showJobQR || showTrackingQR;
    final bool hasBarcodeArea = showBarcode || showJobNo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Row 1: Barcode + QR ──────────────────────────────────────
          if (hasBarcodeArea || hasQR)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Barcode / Job number column
                if (hasBarcodeArea)
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBarcode)
                          SizedBox(
                            height: 56,
                            child: BarcodeWidget(
                              barcode: Barcode.code128(),
                              // Use the real job number as barcode data
                              data: jobData.jobNumber,
                              drawText: false,
                              color: Colors.black,
                            ),
                          ),
                        if (showBarcode && showJobNo) const SizedBox(height: 4),
                        if (showJobNo)
                          Text(
                            jobData.jobNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),

                if (hasBarcodeArea && hasQR) const SizedBox(width: 12),

                // QR code column
                if (hasQR)
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        QrImageView(
                          // Job QR encodes the job number;
                          // Tracking QR encodes a URL with the job number.
                          data: showJobQR
                              ? jobData.jobNumber
                              : 'https://tracking.portal/${jobData.jobNumber}',
                          version: QrVersions.auto,
                          size: 72,
                          backgroundColor: Colors.white,
                          // eyeStyle and dataModuleStyle are optional but
                          // ensure crisp black modules even at high dpi.
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          showJobQR ? 'Job QR' : 'Tracking QR',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

          if ((hasBarcodeArea || hasQR) &&
              (showCustomerName ||
                  showModelBrand ||
                  showDate ||
                  showJobType ||
                  showSymptom ||
                  showPhysicalLocation))
            const SizedBox(height: 10),

          // ── Row 2: Text fields ───────────────────────────────────────
          if (showCustomerName ||
              showModelBrand ||
              showDate ||
              showJobType ||
              showSymptom ||
              showPhysicalLocation)
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (showCustomerName) _labelText(jobData.customerName),
                if (showModelBrand) _labelText(jobData.modelBrand),
                if (showDate) _labelText(jobData.date),
                if (showJobType) _labelText(jobData.jobType),
                if (showSymptom) _labelText(jobData.symptom),
                if (showPhysicalLocation) _labelText(jobData.physicalLocation),
              ],
            ),
        ],
      ),
    );
  }

  /// Small helper so text styling is consistent everywhere.
  static Widget _labelText(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );

  // ── Toggle row ────────────────────────────────────────────────────────────

  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF4A90E2),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
