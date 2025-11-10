import 'dart:ui';

import 'package:another_brother_vitorhp/label_info.dart';
import 'package:another_brother_vitorhp/printer_info.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/constants/app_colors.dart';

class ThermalPrinterScreen extends StatefulWidget {
  const ThermalPrinterScreen({super.key});

  @override
  State<ThermalPrinterScreen> createState() => _ThermalPrinterScreenState();
}

class _ThermalPrinterScreenState extends State<ThermalPrinterScreen> {
  String? selectedPrinter;
  final TextEditingController ipController = TextEditingController(text: '192.169.5.1');
  String selectedProtocol = 'ECS/POS';
  bool isPrinting = false;

  final List<String> protocols = ['ECS/POS', 'STAR', 'EPSON'];

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  Future<void> _testPrint() async {
    if (ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter printer IP address')));
      return;
    }

    setState(() {
      isPrinting = true;
    });

    try {
      // Configure printer info for thermal printer
      var printer = Printer();
      var printInfo = PrinterInfo();

      // Set printer model for thermal printer (80mm)
      printInfo.printerModel = Model.QL_820NWB; // or appropriate 80mm thermal model
      printInfo.port = Port.NET;
      printInfo.ipAddress = ipController.text;

      // Set label info for thermal printing
      var labelInfo = LabelInfo();
      labelInfo.labelNameIndex = QL700.ordinalFromID(QL700.W62.getId());

      await printer.setPrinterInfo(printInfo);

      // Send test print
      var printResult = await printer.printText(
        'Test Print\n\nThermal Printer (80mm)\nConfiguration Test\n\n' as Paragraph,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              printResult.errorCode == ErrorCode.ERROR_NONE
                  ? 'Test print sent successfully!'
                  : 'Print failed: ${printResult.errorCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isPrinting = false;
        });
      }
    }
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
          'Thermal Printer (80mm)',
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
                          items: ['Brother QL-820NWB', 'Brother TD-4550DNWB', 'Thermal Printer 80mm'].map((
                            String value,
                          ) {
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
                      keyboardType: TextInputType.number,
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
                  ],
                ),
              ),
            ),
          ),

          // Test Print Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isPrinting ? null : _testPrint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isPrinting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Test Print', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
