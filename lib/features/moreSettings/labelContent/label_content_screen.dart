import 'package:flutter/material.dart';

class LabelContentScreen extends StatefulWidget {
  const LabelContentScreen({super.key});

  @override
  State<LabelContentScreen> createState() => _LabelContentScreenState();
}

class _LabelContentScreenState extends State<LabelContentScreen> {
  // State variables for each toggle switch
  bool trackingPortalQR = false;
  bool jobQR = true;
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Label Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildToggleItem(
                          'QR-Code (Tracking-Portal)',
                          trackingPortalQR,
                          (value) => setState(() => trackingPortalQR = value),
                        ),
                        _buildToggleItem('QR-Code (Job)', jobQR, (value) => setState(() => jobQR = value)),
                        _buildToggleItem('Job No.', jobNo, (value) => setState(() => jobNo = value)),
                        _buildToggleItem(
                          'Customer Name /Company Name',
                          customerName,
                          (value) => setState(() => customerName = value),
                        ),
                        _buildToggleItem('Model, Brand', modelBrand, (value) => setState(() => modelBrand = value)),
                        _buildToggleItem('Date', date, (value) => setState(() => date = value)),
                        _buildToggleItem('Job type', jobType, (value) => setState(() => jobType = value)),
                        _buildToggleItem('Symptom', symptom, (value) => setState(() => symptom = value)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: const Text('Test Print', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, bool value, ValueChanged<bool> onChanged, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Test Print', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          content: const Text(
            'Are you sure you want to start a test print with the current label configuration?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle print logic here
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Test print started...'), backgroundColor: Color(0xFF4A90E2)),
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Print', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
