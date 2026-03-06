import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/helpers/snakbar_demo.dart';
import '../models/printer_config_model.dart';
import '../service/printer_settings_service.dart';
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
  final TextEditingController _portController = TextEditingController(
    text: '9100',
  );
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
    SnackbarDemo(
      message: 'Form filled with ${printer.printerModel ?? "printer"} settings',
    ).showCustomSnackbar(context);
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
      SnackbarDemo(
        message: 'Printer selected: ${result['ip']}',
      ).showCustomSnackbar(context);
    }
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty && _selectedProtocol == 'RAW/TCP') {
      SnackbarDemo(
        message: 'Please enter IP address',
      ).showCustomSnackbar(context);
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
      SnackbarDemo(
        message: '✅ Settings saved successfully!',
      ).showCustomSnackbar(context);
      _loadSavedPrinters(); // Refresh the list
      _clearForm();
    } catch (e) {
      debugPrint('❌ Failed to save A4 printer config: $e');
      SnackbarDemo(
        message: '❌ Failed to save settings',
      ).showCustomSnackbar(context);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _sendRawTestPrint() async {
    final ip = _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 9100;

    if (ip.isEmpty) {
      SnackbarDemo(
        message: 'Please enter printer IP to test print',
      ).showCustomSnackbar(context);
      return;
    }

    SnackbarDemo(
      message: 'Sending test print to $ip:$port',
    ).showCustomSnackbar(context);

    try {
      debugPrint('📤 [TestPrint] Connecting to $ip:$port');
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      // Initialize printer (ESC @), send text, then form feed
      socket.add([0x1B, 0x40]); // ESC @
      final message = 'RepairCMS Test Print\n\n';
      socket.add(utf8.encode(message));
      socket.add([0x0C]); // form feed

      await socket.flush();
      socket.destroy();

      debugPrint('✅ [TestPrint] Sent test print to $ip:$port');
      SnackbarDemo(
        message: 'Test print sent to $ip:$port',
      ).showCustomSnackbar(context);
    } catch (e) {
      debugPrint('❌ [TestPrint] Error sending test print: $e');
      SnackbarDemo(
        message: 'Failed to send test print: $e',
      ).showCustomSnackbar(context);
    }
  }

  Future<void> _sendTestPrintWithProtocol() async {
    final ip = _ipController.text.trim();
    final protocolName = _selectedProtocol;

    if (ip.isEmpty) {
      SnackbarDemo(
        message: 'Please enter printer IP',
      ).showCustomSnackbar(context);
      return;
    }

    SnackbarDemo(
      message: 'Sending test print via $protocolName...',
    ).showCustomSnackbar(context);

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
      SnackbarDemo(
        message: 'Test print failed: $e',
      ).showCustomSnackbar(context);
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

      final socket = await Socket.connect(
        ip,
        631,
        timeout: const Duration(seconds: 5),
      );
      socket.add(ippRequest);
      await socket.flush();
      socket.destroy();

      SnackbarDemo(
        message: 'IPP test sent to $ip:631',
      ).showCustomSnackbar(context);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendLPRTestPrint(String ip) async {
    try {
      final socket = await Socket.connect(
        ip,
        515,
        timeout: const Duration(seconds: 5),
      );
      socket.add(utf8.encode('RepairCMS LPR Test\n'));
      await socket.flush();
      socket.destroy();
      SnackbarDemo(
        message: 'LPR test attempted to $ip:515',
      ).showCustomSnackbar(context);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _sendHTTPTestPrint(String ip, bool secure) async {
    try {
      final protocol = secure ? 'https' : 'http';
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('$protocol://$ip:${secure ? 443 : 80}/'),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      SnackbarDemo(
        message: 'HTTP ${response.statusCode} from $ip',
      ).showCustomSnackbar(context);
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
        recommendation =
            '✅ Best choice! IPP is modern, secure, and supports duplex, color, and status reporting.';
        color = Colors.green;
        break;
      case 'RAW/TCP':
      case 'TCP':
        recommendation =
            '⚠️ Raw TCP works but lacks features. Consider switching to IPP if available.';
        color = Colors.orange;
        break;
      case 'LPR/LPD':
        recommendation =
            'ℹ️ LPR is common in corporate networks. Check firewall allows port 515.';
        color = Colors.blue;
        break;
      case 'HTTP':
        recommendation =
            '⚠️ HTTP is unencrypted. Use HTTPS if available for security.';
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        SnackbarDemo(
          message: 'Failed to delete printer',
        ).showCustomSnackbar(context);
      }
    }
  }

  Future<void> _setAsDefaultPrinter(PrinterConfigModel printer) async {
    try {
      final updatedPrinter = printer.copyWith(isDefault: true);
      await _settingsService.savePrinterConfig(updatedPrinter);
      SnackbarDemo(
        message: '✅ Set as default printer',
      ).showCustomSnackbar(context);
      _loadSavedPrinters();
    } catch (e) {
      SnackbarDemo(
        message: 'Failed to set default',
      ).showCustomSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: CustomNavButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new,
          ),
        ),
        title: Text(
          'A4 Receipt Printer',
          style: AppTypography.sfProHeadLineTextStyle22,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printer Configuration',
                      style: AppTypography.sfProText15.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Printer Name
                    _buildLabel('Printer Name'),
                    _buildInputField(
                      controller: _printerNameController,
                      hint: 'e.g. Office A4 Printer',
                    ),
                    SizedBox(height: 16.h),

                    // Network Printer Selection
                    _buildLabel('Network Printer'),
                    _buildDropdownField(
                      hint: 'Select Network Printer',
                      value: _savedPrinters.isNotEmpty
                          ? null
                          : null, // Logic for selection
                      items: _savedPrinters
                          .map((p) => p.printerModel ?? p.ipAddress)
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final p = _savedPrinters.firstWhere(
                            (p) => (p.printerModel ?? p.ipAddress) == val,
                          );
                          _fillFormFromPrinter(p);
                        }
                      },
                    ),
                    SizedBox(height: 16.h),

                    // IP Address
                    _buildLabel('IP Address'),
                    _buildInputField(
                      controller: _ipController,
                      hint: '192.169.5.1',
                      suffixIcon: GestureDetector(
                        onTap: _scanForPrinters,
                        child: Icon(
                          Icons.wifi_find,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Protocol
                    _buildLabel('Printer Protocol'),
                    _buildDropdownField(
                      hint: 'Protocol',
                      value: _selectedProtocol,
                      items: [
                        'RAW/TCP',
                        'IPP',
                        'LPR/LPD',
                        'HTTP',
                        'HTTPS',
                        'USB',
                        'System Default',
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedProtocol = val!),
                    ),

                    _getProtocolRecommendationWidget(),

                    SizedBox(height: 16.h),

                    // Port
                    _buildLabel('Port'),
                    _buildInputField(
                      controller: _portController,
                      hint: '9100',
                      keyboardType: TextInputType.number,
                    ),

                    SizedBox(height: 16.h),

                    // Default switch
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _setAsDefault,
                            onChanged: (val) =>
                                setState(() => _setAsDefault = val!),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Set as default printer',
                          style: AppTypography.sfProText15.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Save Settings',
                                style: AppTypography.primaryButtonTextStyle
                                    .copyWith(fontSize: 16.sp),
                              ),
                      ),
                    ),

                    if (_ipController.text.trim().isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton(
                          onPressed: _sendTestPrintWithProtocol,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Test Print',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Saved Printers Section (only if not empty)
            if (_savedPrinters.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Printers',
                      style: AppTypography.sfProText15.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ..._savedPrinters.map(
                      (printer) => _buildSavedPrinterCard(printer),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        label,
        style: AppTypography.sfProText15.copyWith(
          fontSize: 14.sp,
          color: AppColors.fontSecondaryColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.sfProText15,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.sfProText15.copyWith(
          color: AppColors.fontSecondaryColor.withValues(alpha: 0.3),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: AppTypography.sfProText15.copyWith(
              color: AppColors.fontSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
          isExpanded: true,
          style: AppTypography.sfProText15,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSavedPrinterCard(PrinterConfigModel printer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: printer.isDefault
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.print_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  printer.printerModel ?? 'A4 Printer',
                  style: AppTypography.sfProText15.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${printer.ipAddress} • ${printer.protocol}',
                  style: AppTypography.sfProText15.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.fontSecondaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (printer.isDefault)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.fontSecondaryColor,
            ),
            onSelected: (value) {
              if (value == 'use')
                _fillFormFromPrinter(printer);
              else if (value == 'default')
                _setAsDefaultPrinter(printer);
              else if (value == 'delete')
                _deletePrinter(printer);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'use', child: Text('Use')),
              if (!printer.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Text('Set as Default'),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
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
