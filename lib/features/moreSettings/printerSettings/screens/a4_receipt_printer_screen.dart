import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';
import 'package:repair_cms/core/helpers/show_toast.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';

class A4ReceiptPrinterScreen extends StatefulWidget {
  const A4ReceiptPrinterScreen({super.key});

  @override
  State<A4ReceiptPrinterScreen> createState() => _A4ReceiptPrinterScreenState();
}

class _A4ReceiptPrinterScreenState extends State<A4ReceiptPrinterScreen> {
  String? selectedPrinter;
  final TextEditingController ipController = TextEditingController(text: '192.169.5.1');
  String selectedProtocol = 'IPP';
  bool isDefault = false;

  final List<String> protocols = ['IPP', 'LPD', 'RAW'];
  final _printerSettingsService = PrinterSettingsService();

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  /// Load saved printer settings
  void _loadSavedSettings() {
    final savedConfig = _printerSettingsService.getA4Printer();
    if (savedConfig != null) {
      setState(() {
        selectedPrinter = savedConfig.printerModel;
        ipController.text = savedConfig.ipAddress ?? '192.169.5.1';
        selectedProtocol = savedConfig.protocol ?? 'IPP';
        isDefault = savedConfig.isDefault;
      });
    }
  }

  /// Save printer settings
  Future<void> _saveSettings() async {
    if (ipController.text.isEmpty) {
      showCustomToast('Please enter printer IP address', isError: true);
      return;
    }

    final config = PrinterConfigModel(
      printerType: 'a4',
      printerModel: selectedPrinter,
      ipAddress: ipController.text,
      protocol: selectedProtocol,
      isDefault: isDefault,
      lastUpdated: DateTime.now(),
    );

    try {
      await _printerSettingsService.saveA4Printer(config);

      if (isDefault) {
        await _printerSettingsService.setDefaultPrinterType('a4');
      }

      if (mounted) {
        showCustomToast('A4 printer settings saved!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        showCustomToast('Failed to save settings: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  void _testPrint() {
    // Implement A4 printer test print logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sending test print to A4 Receipt Printer...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'A4 Receipt Printer',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Printer Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),

                    // Network Printer Dropdown
                    const Text(
                      'Network Printer',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedPrinter,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Select Network Printer', style: TextStyle(color: Colors.black87)),
                          ),
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                          ),
                          items: ['Printer 1', 'Printer 2', 'Printer 3'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(value)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPrinter = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // IP Address Field
                    const Text(
                      'IP Address',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ipController,
                      decoration: InputDecoration(
                        hintText: '192.169.5.1',
                        hintStyle: const TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Printer Protocol Dropdown
                    const Text(
                      'Printer Protocol',
                      style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedProtocol,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                          ),
                          items: protocols.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(value)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProtocol = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Set as default checkbox
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Set as default receipt printer',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Use this printer for all receipts by default',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      value: isDefault,
                      onChanged: (bool? value) {
                        setState(() {
                          isDefault = value ?? false;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Save Settings Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Test Print Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _testPrint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Test Print', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
