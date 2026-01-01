import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/helpers/snakbar_demo.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
import '../service/protocol_detection_services.dart';
import '../widgets/wifi_printer_scanner.dart';

class A4PrinterScreen extends StatefulWidget {
  const A4PrinterScreen({super.key});

  @override
  State<A4PrinterScreen> createState() => _A4PrinterScreenState();
}

class _A4PrinterScreenState extends State<A4PrinterScreen> {
  final PrinterSettingsService _settingsService = PrinterSettingsService();

  final TextEditingController _printerNameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '9100');
  String _selectedProtocol = 'RAW/TCP';
  bool _setAsDefault = false;
  bool _isSaving = false;

  List<PrinterConfigModel> _savedPrinters = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrinters();
    _ipController.addListener(() => setState(() {}));
  }

  void _loadSavedPrinters() {
    setState(() {
      _savedPrinters = _settingsService.getPrinters('a4');
    });
    debugPrint('📊 Loaded ${_savedPrinters.length} A4 printers');
  }

  void _fillFormFromPrinter(PrinterConfigModel printer) {
    setState(() {
      _printerNameController.text = printer.printerModel ?? '';
      _ipController.text = printer.ipAddress;
      _portController.text = printer.port?.toString() ?? '9100';
      _selectedProtocol = printer.protocol;
      _setAsDefault = printer.isDefault;
    });
    SnackbarDemo(message: 'Form filled with ${printer.printerModel ?? "printer"} settings').showCustomSnackbar(context);
  }

  Future<void> _scanForPrinters() async {
    debugPrint('🔍 Opening WiFi printer scanner for A4 printer');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => WiFiPrinterScanner(
        onPrinterSelected: (String ipAddress, int port) {
          // Fill the form immediately when "Use" is clicked
          setState(() {
            _ipController.text = ipAddress;
            _portController.text = port.toString();
          });
          Navigator.pop(context, {'ip': ipAddress, 'port': port});
        },
      ),
    );

    if (result != null) {
      debugPrint('✅ Selected printer: ${result['ip']}:${result['port']}');
      SnackbarDemo(message: 'Printer selected: ${result['ip']}').showCustomSnackbar(context);
    }
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty && _selectedProtocol == 'RAW/TCP') {
      SnackbarDemo(message: 'Please enter IP address').showCustomSnackbar(context);
      return;
    }

    setState(() => _isSaving = true);

    final config = PrinterConfigModel(
      printerType: 'a4',
      printerBrand: 'Generic',
      printerModel: _printerNameController.text.trim().isEmpty
          ? 'Generic A4 Printer'
          : _printerNameController.text.trim(),
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
    );

    try {
      await _settingsService.savePrinterConfig(config);
      debugPrint('✅ A4 printer config saved: ${config.ipAddress}');
      SnackbarDemo(message: '✅ Settings saved successfully!').showCustomSnackbar(context);
      _loadSavedPrinters(); // Refresh the list
      _clearForm();
    } catch (e) {
      debugPrint('❌ Failed to save A4 printer config: $e');
      SnackbarDemo(message: '❌ Failed to save settings').showCustomSnackbar(context);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _sendRawTestPrint() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(message: 'Please enter printer IP to test print').showCustomSnackbar(context);
      return;
    }

    SnackbarDemo(message: 'Sending test print to $ip:$port').showCustomSnackbar(context);

    try {
      debugPrint('📤 [TestPrint] Connecting to $ip:$port');
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));

      // Initialize printer (ESC @), send text, then form feed
      socket.add([0x1B, 0x40]); // ESC @
      final message = 'RepairCMS Test Print\n\n';
      socket.add(utf8.encode(message));
      socket.add([0x0C]); // form feed

      await socket.flush();
      socket.destroy();

      debugPrint('✅ [TestPrint] Sent test print to $ip:$port');
      SnackbarDemo(message: 'Test print sent to $ip:$port').showCustomSnackbar(context);
    } catch (e) {
      debugPrint('❌ [TestPrint] Error sending test print: $e');
      SnackbarDemo(message: 'Failed to send test print: $e').showCustomSnackbar(context);
    }
  }

  Future<void> _autoDetectProtocol() async {
    var ip = _ipController.text.trim();

    // If no IP provided, open the WiFi scanner to let user pick a printer first
    if (ip.isEmpty) {
      await _scanForPrinters();
      // _scanForPrinters will fill the controllers when a printer is selected.
      ip = _ipController.text.trim();
      if (ip.isEmpty) {
        SnackbarDemo(message: 'Please enter or select a printer IP first').showCustomSnackbar(context);
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final detector = PrinterProtocolDetector();
      final result = await detector.detectProtocols(ip);

      if (!result.isReachable) {
        SnackbarDemo(message: '❌ Printer not reachable at $ip').showCustomSnackbar(context);
        return;
      }

      if (result.recommendedProtocol != null) {
        final protocol = result.recommendedProtocol!;
        final description = PrinterProtocolDetector.getProtocolDescription(protocol);

        setState(() {
          _portController.text = protocol.port.toString();
          _selectedProtocol = protocol.name;
        });

        // Show protocol recommendation
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Protocol Detected'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detected: ${protocol.name} (Port ${protocol.port})'),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 12.h),
                if (result.availableProtocols.length > 1)
                  Text(
                    'Also available: ${result.availableProtocols.where((p) => p != protocol).map((p) => p.name).join(', ')}',
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Use This')),
              if (result.availableProtocols.length > 1)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showProtocolSelector(result.availableProtocols);
                  },
                  child: const Text('Choose Another'),
                ),
            ],
          ),
        );

        SnackbarDemo(message: '✅ Auto-detected ${protocol.name}').showCustomSnackbar(context);
      } else {
        SnackbarDemo(message: '⚠️ No printing protocols detected').showCustomSnackbar(context);
      }
    } catch (e) {
      debugPrint('❌ Protocol detection error: $e');
      SnackbarDemo(message: 'Detection failed: ${e.toString()}').showCustomSnackbar(context);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showProtocolSelector(List<PrinterProtocol> protocols) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Protocol'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: protocols.length,
            itemBuilder: (context, index) {
              final protocol = protocols[index];
              return ListTile(
                title: Text('${protocol.name} (Port ${protocol.port})'),
                subtitle: Text(PrinterProtocolDetector.getProtocolDescription(protocol)),
                onTap: () {
                  setState(() {
                    _portController.text = protocol.port.toString();
                    _selectedProtocol = protocol.name;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _sendTestPrintWithProtocol() async {
    final ip = _ipController.text.trim();
    final protocolName = _selectedProtocol;

    if (ip.isEmpty) {
      SnackbarDemo(message: 'Please enter printer IP').showCustomSnackbar(context);
      return;
    }

    SnackbarDemo(message: 'Sending test print via $protocolName...').showCustomSnackbar(context);

    try {
      switch (protocolName) {
        case 'TCP':
        case 'RAW/TCP':
          await _sendRawTestPrint();
          break;
        case 'IPP':
          await _sendIPPTestPrint(ip);
          break;
        case 'LPR/LPD':
          await _sendLPRTestPrint(ip);
          break;
        case 'HTTP':
          await _sendHTTPTestPrint(ip, false);
          break;
        case 'HTTPS':
          await _sendHTTPTestPrint(ip, true);
          break;
        default:
          await _sendRawTestPrint(); // Fallback
      }
    } catch (e) {
      SnackbarDemo(message: 'Test print failed: $e').showCustomSnackbar(context);
    }
  }

  Future<void> _sendIPPTestPrint(String ip) async {
    try {
      // Simple IPP request (basic header)
      final ippRequest = Uint8List.fromList([
        0x01, 0x01, // Version 1.1
        0x00, 0x02, // Operation Print-Job
        0x00, 0x00, 0x00, 0x01, // Request ID
        0x01, // Operation attributes tag
        0x47, // charset tag
        0x00, 0x12, // name length
        ...utf8.encode('attributes-charset'),
        0x00, 0x05, // value length
        ...utf8.encode('utf-8'),
      ]);

      final socket = await Socket.connect(ip, 631, timeout: const Duration(seconds: 5));
      socket.add(ippRequest);
      await socket.flush();
      socket.destroy();

      SnackbarDemo(message: 'IPP test sent to $ip:631').showCustomSnackbar(context);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendLPRTestPrint(String ip) async {
    try {
      final socket = await Socket.connect(ip, 515, timeout: const Duration(seconds: 5));
      socket.add(utf8.encode('RepairCMS LPR Test\n'));
      await socket.flush();
      socket.destroy();
      SnackbarDemo(message: 'LPR test attempted to $ip:515').showCustomSnackbar(context);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendHTTPTestPrint(String ip, bool secure) async {
    try {
      final protocol = secure ? 'https' : 'http';
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$protocol://$ip:${secure ? 443 : 80}/'));
      final response = await request.close().timeout(const Duration(seconds: 5));
      SnackbarDemo(message: 'HTTP ${response.statusCode} from $ip').showCustomSnackbar(context);
    } catch (e) {
      rethrow;
    }
  }

  Widget _getProtocolRecommendationWidget() {
    final protocol = _selectedProtocol;
    // port is not needed here; recommendation is based on protocol string

    String recommendation = '';
    Color color = Colors.blue;

    switch (protocol) {
      case 'IPP':
        recommendation = '✅ Best choice! IPP is modern, secure, and supports duplex, color, and status reporting.';
        color = Colors.green;
        break;
      case 'RAW/TCP':
      case 'TCP':
        recommendation = '⚠️ Raw TCP works but lacks features. Consider switching to IPP if available.';
        color = Colors.orange;
        break;
      case 'LPR/LPD':
        recommendation = 'ℹ️ LPR is common in corporate networks. Check firewall allows port 515.';
        color = Colors.blue;
        break;
      case 'HTTP':
        recommendation = '⚠️ HTTP is unencrypted. Use HTTPS if available for security.';
        color = Colors.orange;
        break;
    }

    if (recommendation.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                recommendation,
                style: TextStyle(fontSize: 12.sp, color: color),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  void _clearForm() {
    setState(() {
      _printerNameController.clear();
      _ipController.clear();
      _portController.text = '9100';
      _selectedProtocol = 'RAW/TCP';
      _setAsDefault = false;
    });
  }

  Future<void> _deletePrinter(PrinterConfigModel printer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Printer'),
        content: Text('Delete ${printer.printerModel ?? printer.ipAddress}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _settingsService.deletePrinterConfig(printer);
        SnackbarDemo(message: 'Printer deleted').showCustomSnackbar(context);
        _loadSavedPrinters();
      } catch (e) {
        SnackbarDemo(message: 'Failed to delete printer').showCustomSnackbar(context);
      }
    }
  }

  Future<void> _setAsDefaultPrinter(PrinterConfigModel printer) async {
    try {
      final updatedPrinter = printer.copyWith(isDefault: true);
      await _settingsService.savePrinterConfig(updatedPrinter);
      SnackbarDemo(message: '✅ Set as default printer').showCustomSnackbar(context);
      _loadSavedPrinters();
    } catch (e) {
      SnackbarDemo(message: 'Failed to set default').showCustomSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        border: null,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.back, size: 28.r, color: const Color(0xFF007AFF)),
              SizedBox(width: 4.w),
              Text(
                'Back',
                style: TextStyle(fontSize: 17.sp, color: const Color(0xFF007AFF)),
              ),
            ],
          ),
        ),
        middle: Text(
          'A4 Printer',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saved Printers List
            if (_savedPrinters.isNotEmpty) ...[
              Text(
                'Saved Printers',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedPrinters.length,
                itemBuilder: (context, index) {
                  final printer = _savedPrinters[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: printer.isDefault ? Colors.green.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.print,
                          color: printer.isDefault ? Colors.green.shade700 : Colors.grey.shade700,
                          size: 24.sp,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              printer.printerModel ?? 'Generic A4 Printer',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
                            ),
                          ),
                          if (printer.isDefault)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4.r)),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${printer.ipAddress}:${printer.port} (${printer.protocol})',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'use') {
                            _fillFormFromPrinter(printer);
                          } else if (value == 'default') {
                            _setAsDefaultPrinter(printer);
                          } else if (value == 'delete') {
                            _deletePrinter(printer);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'use', child: Text('Use')),
                          if (!printer.isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              Divider(height: 1.h),
              SizedBox(height: 24.h),
            ],

            // Info Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'A4 printers use the system print dialog. Configure network settings below.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Form Title
            Text(
              'Add New Printer',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // Printer Name
            Text(
              'Printer Name (Optional)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _printerNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Office HP Printer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 16.h),

            // IP Address with Scan WiFi and Auto-Detect buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    'IP Address',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: _scanForPrinters,
                  icon: Icon(Icons.wifi_find, size: 18.sp),
                  label: Text('Scan WiFi', style: TextStyle(fontSize: 14.sp)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
                SizedBox(width: 8.w),
                if (_ipController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: _autoDetectProtocol,
                    icon: Icon(Icons.auto_awesome, size: 18.sp),
                    label: Text('Auto-Detect', style: TextStyle(fontSize: 14.sp)),
                    style: TextButton.styleFrom(foregroundColor: Colors.orange),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: 'e.g., 192.168.1.100',
                prefixIcon: const Icon(Icons.router),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16.h),

            // Port
            Text(
              'Port',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                hintText: 'Default: 9100',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),

            // Protocol
            Text(
              'Protocol',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedProtocol,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              items: ['RAW/TCP', 'IPP', 'LPR/LPD', 'HTTP', 'HTTPS', 'USB', 'System Default'].map((protocol) {
                return DropdownMenuItem(value: protocol, child: Text(protocol));
              }).toList(),
              onChanged: (value) => setState(() => _selectedProtocol = value!),
            ),
            SizedBox(height: 12.h),
            _getProtocolRecommendationWidget(),
            SizedBox(height: 8.h),

            // Set as Default
            CheckboxListTile(
              title: const Text('Set as default A4 printer'),
              value: _setAsDefault,
              onChanged: (value) => setState(() => _setAsDefault = value!),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 24.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Settings',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 12.h),

            // Test Print Buttons (visible when IP is provided)
            if (_ipController.text.trim().isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: _sendTestPrintWithProtocol,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Test Print (Selected Protocol)', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: _sendRawTestPrint,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Test Raw Print', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _printerNameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
