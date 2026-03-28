import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';

class CustomDropdownSearch<T> extends StatelessWidget {
  final TextEditingController controller;
  final List<T> items;
  final String hintText;
  final String noItemsText;
  final Function(T) onSuggestionSelected;
  final Widget Function(BuildContext, T) itemBuilder;
  final List<T> Function(String) suggestionsCallback;
  final bool displayAllSuggestionWhenTap;
  final bool isMultiSelectDropdown;
  final double? maxHeight;
  final Color? suggestionsBoxColor;
  final TextFieldConfiguration? textFieldConfiguration;

  const CustomDropdownSearch({
    super.key,
    required this.controller,
    required this.items,
    required this.hintText,
    required this.onSuggestionSelected,
    required this.itemBuilder,
    required this.suggestionsCallback,
    this.noItemsText = 'No items found',
    this.displayAllSuggestionWhenTap = true,
    this.isMultiSelectDropdown = false,
    this.maxHeight,
    this.suggestionsBoxColor,
    this.textFieldConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    return DropDownSearchField<T>(
      displayAllSuggestionWhenTap: displayAllSuggestionWhenTap,
      isMultiSelectDropdown: isMultiSelectDropdown,
      itemBuilder: itemBuilder,
      suggestionsCallback: suggestionsCallback,
      textFieldConfiguration:
          textFieldConfiguration ??
          TextFieldConfiguration(
            controller: controller,
            style: GoogleFonts.roboto(
              fontSize: 32.sp,
              color: AppColors.fontMainColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                ), // You can customize this
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.roboto(
                fontSize: 32.sp,
                color: Color(0xFFB2B5BE),
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.fontMainColor,
                size: 32,
              ),
            ),
          ),
      onSuggestionSelected: onSuggestionSelected,
      noItemsFoundBuilder: (context) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(noItemsText, style: TextStyle(fontSize: 14)),
      ),
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        elevation: 4,
        color: suggestionsBoxColor ?? AppColors.whiteColor,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        constraints: BoxConstraints(maxHeight: maxHeight ?? 200.h),
      ),
    );
  }
}
