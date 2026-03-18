import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/printer_config_model.dart';

class PrinterConfigurationForm extends StatefulWidget {
  final String printerType; // 'thermal', 'label', 'a4'
  final PrinterConfigModel? initialConfig;
  final List<String> supportedBrands;
  final Map<String, List<String>> brandModels;
  final Function(PrinterConfigModel) onSave;
  final Function(PrinterConfigModel) onTestPrint;
  final Function(PrinterConfigModel)? onTestLabel; // Optional for label printers
  final VoidCallback onScan;
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

  // Type specific fields
  int? _paperWidth; // For thermal
  LabelSize? _selectedLabelSize; // For label

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialConfig?.printerBrand ?? (widget.supportedBrands.isNotEmpty ? widget.supportedBrands.first : 'Generic');
    _selectedModel = widget.initialConfig?.printerModel;
    _ipController = TextEditingController(text: widget.initialConfig?.ipAddress ?? '');
    _portController = TextEditingController(text: widget.initialConfig?.port?.toString() ?? '9100');
    _selectedProtocol = widget.initialConfig?.protocol ?? 'TCP';
    _setAsDefault = widget.initialConfig?.isDefault ?? false;

    if (widget.printerType == 'thermal') {
      _paperWidth = widget.initialConfig?.paperWidth ?? 80;
    } else if (widget.printerType == 'label') {
      _selectedLabelSize = widget.initialConfig?.labelSize;
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Printer Configuration',
            style: AppTypography.sfProHeadLineTextStyle22.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 24.h),

          _buildLabel('Printer Brand'),
          _buildDropdownField(
            hint: 'Select Brand',
            value: _selectedBrand,
            items: widget.supportedBrands,
            onChanged: (value) {
              setState(() {
                _selectedBrand = value!;
                _selectedModel = null;
                if (widget.printerType == 'label') _selectedLabelSize = null;
              });
            },
          ),
          SizedBox(height: 16.h),

          _buildLabel('Printer Model'),
          _buildDropdownField(
            hint: 'Select Model',
            value: _selectedModel,
            items: widget.brandModels[_selectedBrand] ?? [],
            onChanged: (value) {
              setState(() {
                _selectedModel = value;
                if (widget.printerType == 'label' && value != null && _selectedBrand == 'Brother') {
                   if (value.startsWith('TD-4')) {
                    _selectedLabelSize = LabelSize(width: 100, height: 150, name: '100x150 (TD-4)');
                  } else if (value.startsWith('TD-2')) {
                    _selectedLabelSize = LabelSize(width: 50, height: 26, name: '50x26 (TD-2)');
                  }
                }
              });
            },
          ),
          SizedBox(height: 16.h),

          if (widget.printerType == 'thermal') ...[
            _buildLabel('Paper Width'),
            _buildDropdownFieldGeneric<int>(
              hint: 'Select Width',
              value: _paperWidth,
              items: [80, 58],
              itemBuilder: (width) => '${width}mm ${width == 80 ? '(Standard)' : '(Compact)'}',
              onChanged: (value) => setState(() => _paperWidth = value),
            ),
            SizedBox(height: 16.h),
          ],

          if (widget.printerType == 'label') ...[
            _buildLabel('Label Size'),
             _buildDropdownFieldGeneric<LabelSize>(
                hint: 'Select Size',
                value: _selectedLabelSize,
                items: _getLabelSizesForBrand(),
                itemBuilder: (size) => '${size.name} (${size.width}×${size.height} mm)',
                onChanged: (value) => setState(() => _selectedLabelSize = value),
              ),
            SizedBox(height: 16.h),
          ],

          _buildLabel('IP Address'),
          _buildInputField(
            controller: _ipController,
            hint: '192.169.5.1',
            suffixIcon: IconButton(
              icon: const Icon(Icons.wifi_find, color: AppColors.primary),
              onPressed: () async {
                widget.onScan();
                // We'll trust that the screen's scan logic updates the controller or state correctly.
                // In a more complex setup, we'd pass back the selected IP to this form.
              },
            ),
          ),
          SizedBox(height: 16.h),

          _buildLabel('Port'),
          _buildInputField(
            controller: _portController,
            hint: '9100',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),

          _buildLabel('Printer Protocol'),
          _buildDropdownField(
            hint: 'Protocol',
            value: _selectedProtocol,
            items: widget.printerType == 'a4' 
              ? ['RAW/TCP', 'IPP', 'LPR/LPD', 'HTTP', 'HTTPS', 'System Default']
              : widget.printerType == 'thermal' ? ['TCP', 'USB'] : ['TCP', 'IPP', 'USB'],
            onChanged: (value) {
              setState(() {
                _selectedProtocol = value!;
                if (value == 'IPP') _portController.text = '631';
                else if (value == 'TCP' || value == 'RAW/TCP') _portController.text = '9100';
              });
            },
          ),
          SizedBox(height: 24.h),

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
              Text(
                'Set as default printer',
                style: AppTypography.sfProText15.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: widget.isSaving ? null : () {
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: widget.isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Save Settings', style: AppTypography.primaryButtonTextStyle.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 16.h),

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

  Widget _buildDropdownField({
    required String hint,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: AppTypography.sfProText15.copyWith(color: AppColors.fontSecondaryColor.withValues(alpha: 0.3))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontSecondaryColor),
          isExpanded: true,
          style: AppTypography.sfProText15,
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownFieldGeneric<T>({
    required String hint,
    T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: AppTypography.sfProText15.copyWith(color: AppColors.fontSecondaryColor.withValues(alpha: 0.3))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.fontSecondaryColor),
          isExpanded: true,
          style: AppTypography.sfProText15,
          items: items.map((T item) => DropdownMenuItem<T>(value: item, child: Text(itemBuilder(item)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
