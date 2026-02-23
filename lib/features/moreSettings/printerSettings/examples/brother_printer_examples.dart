import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../service/brother_sdk_printer_service.dart';

/// Example usage class for Brother SDK Printer Service
///
/// This demonstrates how to use the BrotherSDKPrinterService to print
/// labels on Brother TD-2D, TD-4D, QL, and PT series printers.
class BrotherPrinterExamples {
  final BrotherSDKPrinterService _printerService = BrotherSDKPrinterService();

  /// Example 1: Print a simple text label
  Future<void> printSimpleText(String ipAddress) async {
    final result = await _printerService.printLabel(ipAddress: ipAddress, text: 'Repair ID: 1001\nStatus: Pending');

    if (result.success) {
      debugPrint('✅ Text label printed successfully');
    } else {
      debugPrint('❌ Print failed: ${result.message}');
    }
  }

  /// Example 2: Print a QR code label
  /// Since the SDK service handles PDF printing, we can send a PDF with a QR code
  /// OR use the printLabelImage method if we have the image bytes.
  Future<void> printQRCode(String ipAddress, Uint8List qrImageBytes) async {
    final result = await _printerService.printLabelImage(ipAddress: ipAddress, imageBytes: qrImageBytes);

    if (result.success) {
      debugPrint('✅ QR code label printed successfully');
    } else {
      debugPrint('❌ Print failed: ${result.message}');
    }
  }

  /// Example 3: Check printer status before printing
  Future<bool> checkPrinterStatus(String ipAddress) async {
    final status = await _printerService.getPrinterStatus(ipAddress: ipAddress);

    if (status.isConnected) {
      debugPrint('✅ Printer is ready: ${status.message}');
      return true;
    } else {
      debugPrint('❌ Printer not ready: ${status.message}');
      return false;
    }
  }

  /// Example 4: Print repair job label with data map
  Future<void> printJobLabel(String ipAddress, Map<String, String> data) async {
    final result = await _printerService.printDeviceLabel(ipAddress: ipAddress, labelData: data);

    if (result.success) {
      debugPrint('✅ Job label printed successfully');
    } else {
      debugPrint('❌ Print failed: ${result.message}');
    }
  }
}

/// Widget example showing how to integrate Brother printing in a Flutter UI
class BrotherPrinterTestScreen extends StatefulWidget {
  const BrotherPrinterTestScreen({super.key});

  @override
  State<BrotherPrinterTestScreen> createState() => _BrotherPrinterTestScreenState();
}

class _BrotherPrinterTestScreenState extends State<BrotherPrinterTestScreen> {
  final BrotherSDKPrinterService _printerService = BrotherSDKPrinterService();
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.100');
  String _statusMessage = '';
  bool _isLoading = false;

  Future<void> _testPrint() async {
    setState(() => _isLoading = true);
    final result = await _printerService.printLabel(
      ipAddress: _ipController.text,
      text: 'Brother SDK Test Print\nTime: ${DateTime.now().hour}:${DateTime.now().minute}',
    );
    setState(() {
      _isLoading = false;
      _statusMessage = result.success ? '✅ Print Success' : '❌ ${result.message}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brother SDK Print Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'Printer IP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testPrint,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Print Test'),
            ),
            const SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
