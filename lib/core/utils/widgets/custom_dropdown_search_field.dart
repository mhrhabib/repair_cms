import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_cms/core/app_exports.dart';

class CustomDropdownSearch<T> extends StatefulWidget {
  /// Builds a [TextSpan] that highlights [query] matches within [text].
  /// Use this inside your [itemBuilder] to highlight the search keyword.
  // target: lib/core/utils/widgets/custom_dropdown_search_field.dart

  static Widget highlightedText({
    required String text,
    required String query,
    TextStyle? style,
    TextStyle? highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    final baseStyle = style ?? const TextStyle();

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style:
              highlightStyle ??
              baseStyle.copyWith(
                backgroundColor: const Color(0xFFFEF3C7), // 👈 Yellow highlight logic
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
        ),
      );
      start = index + query.length;
    }
    return RichText(text: TextSpan(children: spans));
  }

  final TextEditingController controller;
  final FocusNode? focusNode;
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
  final bool showSuggestionsWhenEmpty;

  const CustomDropdownSearch({
    super.key,
    required this.controller,
    this.focusNode,
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
    this.showSuggestionsWhenEmpty = false,
  });

  @override
  State<CustomDropdownSearch<T>> createState() => _CustomDropdownSearchState<T>();
}

class _CustomDropdownSearchState<T> extends State<CustomDropdownSearch<T>> {
  final SuggestionsBoxController _suggestionsBoxController = SuggestionsBoxController();
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isOpen = hasFocus;
        });
      },
      child: DropDownSearchField<T>(
        displayAllSuggestionWhenTap: widget.displayAllSuggestionWhenTap,
        isMultiSelectDropdown: widget.isMultiSelectDropdown,
        itemBuilder: widget.itemBuilder,
        suggestionsCallback: (pattern) {
          if (!widget.showSuggestionsWhenEmpty && pattern.isEmpty) {
            return [];
          }
          return widget.suggestionsCallback(pattern);
        },
        suggestionsBoxController: _suggestionsBoxController,
        textFieldConfiguration:
            widget.textFieldConfiguration ??
            TextFieldConfiguration(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: GoogleFonts.roboto(fontSize: 22.sp, color: AppColors.fontMainColor),
              cursorColor: AppColors.warningColor,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                hintText: widget.hintText,
                hintStyle: GoogleFonts.roboto(fontSize: 22.sp, color: Color(0xFFB2B5BE)),
                suffixIcon: Icon(
                  _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.fontMainColor,
                  size: 32,
                ),
              ),
            ),
        onSuggestionSelected: widget.onSuggestionSelected,
        noItemsFoundBuilder: (context) => Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(widget.noItemsText, style: TextStyle(fontSize: 14)),
        ),
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          elevation: 4,
          color: widget.suggestionsBoxColor ?? AppColors.whiteColor,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 200.h),
        ),
      ),
    );
  }
}
