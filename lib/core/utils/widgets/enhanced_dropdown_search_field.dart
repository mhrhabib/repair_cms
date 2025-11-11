import 'package:repair_cms/core/app_exports.dart';

class EnhancedDropdownSearch<T> extends StatefulWidget {
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
  final Widget Function(BuildContext, String)? noItemsFoundBuilder;
  final Widget Function(BuildContext, String, List<T>)? customSuggestionBuilder;
  final FocusNode? focusNode;
  final bool showCreateOption;

  const EnhancedDropdownSearch({
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
    this.noItemsFoundBuilder,
    this.customSuggestionBuilder,
    this.focusNode,
    this.showCreateOption = true,
  });

  @override
  State<EnhancedDropdownSearch<T>> createState() => _EnhancedDropdownSearchState<T>();
}

class _EnhancedDropdownSearchState<T> extends State<EnhancedDropdownSearch<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  late FocusNode _effectiveFocusNode;
  List<T> _filteredItems = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? _focusNode;
    _effectiveFocusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay();
    _effectiveFocusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_isDisposed) return;

    if (_effectiveFocusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    if (_isDisposed) return;

    if (_overlayEntry != null) {
      _updateOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    if (!mounted) return;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 48.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60.h),
          child: _buildSuggestionsList(),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
    }
  }

  void _updateOverlay() {
    if (_isDisposed || _overlayEntry == null) return;
    _overlayEntry?.markNeedsBuild();
  }

  Widget _buildSuggestionsList() {
    if (_isDisposed || !mounted) return const SizedBox.shrink();

    final pattern = widget.controller.text;
    _filteredItems = widget.suggestionsCallback(pattern);

    // Show all items when field is focused and empty (if displayAllSuggestionWhenTap is true)
    if (pattern.isEmpty && widget.displayAllSuggestionWhenTap) {
      _filteredItems = widget.items;
    }

    final hasCustomSuggestion = widget.customSuggestionBuilder != null && pattern.isNotEmpty && widget.showCreateOption;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 300.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: _filteredItems.isEmpty
            ? _buildNoItemsFound(pattern)
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredItems.length + (hasCustomSuggestion ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _filteredItems.length) {
                    final item = _filteredItems[index];
                    return InkWell(
                      onTap: () {
                        if (_isDisposed) return;
                        widget.onSuggestionSelected(item);

                        _effectiveFocusNode.unfocus();
                        _removeOverlay();
                      },
                      child: widget.itemBuilder(context, item),
                    );
                  } else {
                    return widget.customSuggestionBuilder!(context, pattern, _filteredItems);
                  }
                },
              ),
      ),
    );
  }

  Widget _buildNoItemsFound(String pattern) {
    if (widget.noItemsFoundBuilder != null) {
      return widget.noItemsFoundBuilder!(context, pattern);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.customSuggestionBuilder != null && pattern.isNotEmpty && widget.showCreateOption)
          widget.customSuggestionBuilder!(context, pattern, _filteredItems)
        else
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(widget.noItemsText, style: const TextStyle(fontSize: 14)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _effectiveFocusNode,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade400),
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600, size: 24),
        ),
        onTap: () {
          if (!_effectiveFocusNode.hasFocus) {
            _effectiveFocusNode.requestFocus();
          }
        },
      ),
    );
  }
}
