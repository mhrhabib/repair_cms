import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:repair_cms/core/app_exports.dart';

void main() {
  final picker = const FlCountryCodePicker();
  for (var c in picker.countryCodes.take(5)) {
    debugPrint('Name: ${c.name}, Code: ${c.code}, DialCode: ${c.dialCode}');
  }
}
