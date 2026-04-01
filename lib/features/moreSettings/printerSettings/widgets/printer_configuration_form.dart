import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/widgets/custom_dropdown_search_field.dart';
import '../models/printer_config_model.dart';

class PrinterConfigurationForm extends StatefulWidget {
  final String printerType; // 'thermal', 'label', 'a4'
  final PrinterConfigModel? initialConfig;
  final List<String> supportedBrands;
  final Map<String, List<String>> brandModels;
  final Function(PrinterConfigModel) onSave;
  final Function(PrinterConfigModel) onTestPrint;
  final Function(PrinterConfigModel)? onTestLabel; // Optional for label printers
  final Future<Map<String, dynamic>?> Function() onScan;
  final bool isSaving;
  final bool isPrinting;

  const PrinterConfigurationForm({
    super.key,
    required this.printerType,
    this.initialConfig,
    required this.supportedBrands,
    required this.brandModels,
    required this.onSave,
    required this.onTestPrint,
    this.onTestLabel,
    required this.onScan,
    this.isSaving = false,
    this.isPrinting = false,
  });

  @override
  State<PrinterConfigurationForm> createState() => _PrinterConfigurationFormState();
}

class _PrinterConfigurationFormState extends State<PrinterConfigurationForm> {
  late String _selectedBrand;
  String? _selectedModel;
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late String _selectedProtocol;
  late bool _setAsDefault;

  // Controllers for CustomDropdownSearch fields
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _protocolController;
  late TextEditingController _paperWidthController;
  late TextEditingController _labelSizeController;

  // Type specific fields
  int? _paperWidth; // For thermal
  LabelSize? _selectedLabelSize; // For label

  List<String> get _protocolItems => widget.printerType == 'a4'
      ? ['RAW/TCP', 'IPP', 'LPR/LPD', 'HTTP', 'HTTPS', 'System Default']
      : widget.printerType == 'thermal'
      ? ['TCP', 'USB']
      : ['TCP', 'IPP', 'USB'];

  @override
  void initState() {
    super.initState();
    _selectedBrand =
        widget.initialConfig?.printerBrand ??
        (widget.supportedBrands.isNotEmpty ? widget.supportedBrands.first : 'Generic');
    _selectedModel = widget.initialConfig?.printerModel;
    _ipController = TextEditingController(text: widget.initialConfig?.ipAddress ?? '');
    _portController = TextEditingController(text: widget.initialConfig?.port?.toString() ?? '9100');
    _selectedProtocol = widget.initialConfig?.protocol ?? 'TCP';

    if (widget.printerType == 'thermal') {
      _paperWidth = widget.initialConfig?.paperWidth ?? 80;
    } else if (widget.printerType == 'label') {
      _selectedLabelSize = widget.initialConfig?.labelSize;
    }

    _setAsDefault = widget.initialConfig?.isDefault ?? false;

    // Initialize text controllers for dropdowns
    _brandController = TextEditingController(text: _selectedBrand);
    _modelController = TextEditingController(text: _selectedModel ?? '');
    _protocolController = TextEditingController(text: _selectedProtocol);
    _paperWidthController = TextEditingController(
      text: _paperWidth != null ? '${_paperWidth}mm ${_paperWidth == 80 ? '(Standard)' : '(Compact)'}' : '',
    );
    _labelSizeController = TextEditingController(
      text: _selectedLabelSize != null
          ? '${_selectedLabelSize!.name} (${_selectedLabelSize!.width}×${_selectedLabelSize!.height} mm)'
          : '',
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _protocolController.dispose();
    _paperWidthController.dispose();
    _labelSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Printer Configuration',
            style: AppTypography.sfProHeadLineTextStyle22.copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          SizedBox(height: 24.h),

          // Brand
          _buildLabel('Printer Brand'),
          CustomDropdownSearch<String>(
            controller: _brandController,
            textFieldConfiguration: TextFieldConfiguration(
              controller: _brandController,
              style: GoogleFonts.roboto(fontSize: 16.sp, color: AppColors.fontMainColor),
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // You can customize this
                ),
                hintText: 'Select Brand',
                hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Color(0xFFB2B5BE)),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontMainColor, size: 32),
              ),
            ),
            items: widget.supportedBrands,
            hintText: 'Select Brand',
            suggestionsCallback: (query) =>
                widget.supportedBrands.where((b) => b.toLowerCase().contains(query.toLowerCase())).toList(),
            itemBuilder: (context, brand) => ListTile(title: Text(brand, style: AppTypography.sfProText15)),
            onSuggestionSelected: (brand) {
              setState(() {
                _selectedBrand = brand;
                _brandController.text = brand;
                _selectedModel = null;
                _modelController.clear();
                if (widget.printerType == 'label') {
                  _selectedLabelSize = null;
                  _labelSizeController.clear();
                }
              });
            },
          ),
          SizedBox(height: 16.h),

          // Model
          _buildLabel('Printer Model'),
          CustomDropdownSearch<String>(
            controller: _modelController,
            items: widget.brandModels[_selectedBrand] ?? [],
            textFieldConfiguration: TextFieldConfiguration(
              controller: _modelController,
              style: GoogleFonts.roboto(fontSize: 16.sp, color: AppColors.fontMainColor),
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // You can customize this
                ),
                hintText: 'Select Model',
                hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Color(0xFFB2B5BE)),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontMainColor, size: 32),
              ),
            ),
            hintText: 'Select Model',
            suggestionsCallback: (query) {
              final models = widget.brandModels[_selectedBrand] ?? [];
              return models.where((m) => m.toLowerCase().contains(query.toLowerCase())).toList();
            },
            itemBuilder: (context, model) => ListTile(title: Text(model, style: AppTypography.sfProText15)),
            onSuggestionSelected: (model) {
              setState(() {
                _selectedModel = model;
                _modelController.text = model;
                if (widget.printerType == 'label' && _selectedBrand == 'Brother') {
                  if (model.startsWith('TD-4')) {
                    _selectedLabelSize = LabelSize(width: 100, height: 150, name: '100x150 (TD-4)');
                  } else if (model.startsWith('TD-2')) {
                    _selectedLabelSize = LabelSize(width: 50, height: 26, name: '50x26 (TD-2)');
                  }
                  if (_selectedLabelSize != null) {
                    _labelSizeController.text =
                        '${_selectedLabelSize!.name} (${_selectedLabelSize!.width}×${_selectedLabelSize!.height} mm)';
                  }
                }
              });
            },
          ),
          SizedBox(height: 16.h),

          // Paper Width (thermal only)
          if (widget.printerType == 'thermal') ...[
            _buildLabel('Paper Width'),
            CustomDropdownSearch<int>(
              controller: _paperWidthController,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _paperWidthController,
                style: GoogleFonts.roboto(fontSize: 16.sp, color: AppColors.fontMainColor),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // You can customize this
                  ),
                  hintText: 'Select Width',
                  hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Color(0xFFB2B5BE)),
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontMainColor, size: 32),
                ),
              ),
              items: const [80, 58],
              hintText: 'Select Width',
              suggestionsCallback: (query) => [80, 58].where((w) => '${w}mm'.contains(query) || query.isEmpty).toList(),
              itemBuilder: (context, width) => ListTile(
                title: Text('${width}mm ${width == 80 ? '(Standard)' : '(Compact)'}', style: AppTypography.sfProText15),
              ),
              onSuggestionSelected: (width) {
                setState(() {
                  _paperWidth = width;
                  _paperWidthController.text = '${width}mm ${width == 80 ? '(Standard)' : '(Compact)'}';
                });
              },
            ),
            SizedBox(height: 16.h),
          ],

          // Label Size (label only)
          if (widget.printerType == 'label') ...[
            _buildLabel('Label Size'),
            CustomDropdownSearch<LabelSize>(
              controller: _labelSizeController,
              items: _getLabelSizesForBrand(),
              textFieldConfiguration: TextFieldConfiguration(
                controller: _labelSizeController,
                style: GoogleFonts.roboto(fontSize: 16.sp, color: AppColors.fontMainColor),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue), // You can customize this
                  ),
                  hintText: 'Select Width',
                  hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Color(0xFFB2B5BE)),
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontMainColor, size: 32),
                ),
              ),
              hintText: 'Select Size',
              suggestionsCallback: (query) =>
                  _getLabelSizesForBrand().where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList(),
              itemBuilder: (context, size) => ListTile(
                title: Text('${size.name} (${size.width}×${size.height} mm)', style: AppTypography.sfProText15),
              ),
              onSuggestionSelected: (size) {
                setState(() {
                  _selectedLabelSize = size;
                  _labelSizeController.text = '${size.name} (${size.width}×${size.height} mm)';
                });
              },
            ),
            SizedBox(height: 16.h),
          ],

          // IP Address
          _buildLabel('IP Address'),
          _buildInputField(
            controller: _ipController,
            hint: '192.169.5.1',
            suffixIcon: IconButton(
              icon: const Icon(Icons.wifi_find, color: AppColors.primary),
              onPressed: () async {
                final result = await widget.onScan();
                if (result != null && result['ip'] != null) {
                  setState(() {
                    _ipController.text = result['ip'];
                    if (result['port'] != null) {
                      _portController.text = result['port'].toString();
                    }
                  });
                }
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Port
          _buildLabel('Port'),
          _buildInputField(controller: _portController, hint: '9100', keyboardType: TextInputType.number),
          SizedBox(height: 16.h),

          // Protocol
          _buildLabel('Printer Protocol'),
          CustomDropdownSearch<String>(
            controller: _protocolController,
            textFieldConfiguration: TextFieldConfiguration(
              controller: _protocolController,
              style: GoogleFonts.roboto(fontSize: 16.sp, color: AppColors.fontMainColor),
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue), // You can customize this
                ),
                hintText: 'Select Protocol',
                hintStyle: GoogleFonts.roboto(fontSize: 16.sp, color: Color(0xFFB2B5BE)),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontMainColor, size: 32),
              ),
            ),
            items: _protocolItems,
            hintText: 'Select Protocol',
            suggestionsCallback: (query) =>
                _protocolItems.where((p) => p.toLowerCase().contains(query.toLowerCase())).toList(),
            itemBuilder: (context, protocol) => ListTile(title: Text(protocol, style: AppTypography.sfProText15)),
            onSuggestionSelected: (protocol) {
              setState(() {
                _selectedProtocol = protocol;
                _protocolController.text = protocol;
                if (protocol == 'IPP') {
                  _portController.text = '631';
                } else if (protocol == 'TCP' || protocol == 'RAW/TCP') {
                  _portController.text = '9100';
                }
              });
            },
          ),
          SizedBox(height: 24.h),

          // Set as default checkbox
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _setAsDefault,
                  onChanged: (val) => setState(() => _setAsDefault = val!),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                ),
              ),
              SizedBox(width: 8.w),
              Text('Set as default printer', style: AppTypography.sfProText15.copyWith(fontSize: 14.sp)),
            ],
          ),
          SizedBox(height: 32.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: widget.isSaving
                  ? null
                  : () {
                      final config = PrinterConfigModel(
                        printerType: widget.printerType,
                        printerBrand: _selectedBrand,
                        printerModel: _selectedModel,
                        ipAddress: _ipController.text.trim(),
                        protocol: _selectedProtocol,
                        port: int.tryParse(_portController.text),
                        isDefault: _setAsDefault,
                        paperWidth: _paperWidth,
                        labelSize: _selectedLabelSize,
                      );
                      widget.onSave(config);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                elevation: 0,
              ),
              child: widget.isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Save Settings',
                      style: AppTypography.primaryButtonTextStyle.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),

          // Test print buttons
          if (_ipController.text.trim().isNotEmpty) ...[
            if (widget.printerType == 'label')
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryButton(
                      onPressed: widget.isPrinting ? null : () => widget.onTestPrint(_getCurrentConfig()),
                      text: 'Test Receipt',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSecondaryButton(
                      onPressed: widget.isPrinting ? null : () => widget.onTestLabel?.call(_getCurrentConfig()),
                      text: 'Test Label',
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: _buildSecondaryButton(
                  onPressed: widget.isPrinting ? null : () => widget.onTestPrint(_getCurrentConfig()),
                  text: 'Test Print',
                ),
              ),
          ],
        ],
      ),
    );
  }

  PrinterConfigModel _getCurrentConfig() {
    return PrinterConfigModel(
      printerType: widget.printerType,
      printerBrand: _selectedBrand,
      printerModel: _selectedModel,
      ipAddress: _ipController.text.trim(),
      protocol: _selectedProtocol,
      port: int.tryParse(_portController.text),
      isDefault: _setAsDefault,
      paperWidth: _paperWidth,
      labelSize: _selectedLabelSize,
    );
  }

  Widget _buildSecondaryButton({required VoidCallback? onPressed, required String text}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        padding: EdgeInsets.symmetric(vertical: 16.h),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.primary, fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<LabelSize> _getLabelSizesForBrand() {
    if (_selectedBrand == 'Brother') return LabelSize.getBrotherSizes();
    if (_selectedBrand == 'Dymo') return LabelSize.getDymoSizes();
    if (_selectedBrand == 'Xprinter') return LabelSize.getXprinterSizes();
    return [];
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
        hintStyle: AppTypography.sfProText15.copyWith(color: AppColors.fontSecondaryColor.withValues(alpha: 0.3)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.scaffoldBackgroundColor.withValues(alpha: 0.5),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
