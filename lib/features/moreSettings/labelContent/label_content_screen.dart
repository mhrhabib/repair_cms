import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LabelContentScreen extends StatefulWidget {
  const LabelContentScreen({super.key});

  @override
  State<LabelContentScreen> createState() => _LabelContentScreenState();
}

class _LabelContentScreenState extends State<LabelContentScreen> {
  // State variables for each toggle switch
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Label Content',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Label Preview Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                const Text(
                  'Label Preview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabelPreview(),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  const Text(
                    'Label Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                            if (value)
                              jobQR =
                                  false; // Turn off Job QR when Tracking is enabled
                          }),
                        ),
                        _buildToggleItem(
                          'QR-Code (Job)',
                          jobQR,
                          (value) => setState(() {
                            jobQR = value;
                            if (value)
                              trackingPortalQR =
                                  false; // Turn off Tracking QR when Job is enabled
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
                          'Customer Name /Company Name',
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
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Handle test print action
                  _showTestPrintDialog();
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  void _showTestPrintDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Test Print',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Are you sure you want to start a test print with the current label configuration?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle print logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Print', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabelPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barcode and QR Code Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barcode Section
              if (barcode || jobNo)
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      if (barcode)
                        SizedBox(
                          height: 50,
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: '0000123456789',
                            drawText: false,
                          ),
                        ),
                      if (barcode && jobNo) const SizedBox(height: 4),
                      if (jobNo)
                        const Text(
                          'JOB-12345',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              if ((barcode || jobNo) && (jobQR || trackingPortalQR))
                const SizedBox(width: 12),
              // QR Code Section
              if (jobQR || trackingPortalQR)
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      QrImageView(
                        data: jobQR
                            ? 'JOB-12345'
                            : 'https://tracking.portal/12345',
                        version: QrVersions.auto,
                        size: 70,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        jobQR ? 'Job QR' : 'Tracking QR',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Text Information
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (customerName)
                Text(
                  'John Doe',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              if (modelBrand)
                Text(
                  'Apple iPhone 13 Pro',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              if (date)
                Text(
                  '05 Jan 2026',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              if (jobType)
                Text(
                  'Screen Repair',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              if (symptom)
                Text(
                  'Cracked screen, battery issue',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              if (physicalLocation)
                Text(
                  'BOX A-12',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
