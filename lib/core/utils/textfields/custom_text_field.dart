import 'package:repair_cms/core/app_exports.dart';

class CustomTextFormField extends StatefulWidget {
  final String title;
  final TextInputType keyboardType;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final double titleWidth;

  const CustomTextFormField({
    super.key,
    required this.title,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.onChanged,
    this.validator,
    this.titleWidth = 80,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final TextEditingController _controller = TextEditingController();
  bool _isCompleted = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkCompletion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkCompletion() {
    setState(() {
      _isCompleted = _controller.text.isNotEmpty;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title as prefix
        Container(
          width: widget.titleWidth.w,
          padding: EdgeInsets.only(top: 14.h),
          child: Text(
            widget.title,
            style: AppTypography.sfProHeadLineTextStyle28.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Text field
        Expanded(
          child: TextFormField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            validator: widget.validator,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  widget.isPassword ? Icons.lock_outline : Icons.email_outlined,
                  size: 20.w,
                  color: Colors.grey[600],
                ),
              ),
              suffixIcon: _isCompleted
                  ? widget.isPassword
                        ? IconButton(
                            icon: Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: Icon(
                                Icons.question_mark,
                                size: 14.w,
                                color: Colors.grey[600],
                              ),
                            ),
                            onPressed: _toggleObscureText,
                          )
                        : Icon(
                            Icons.check_circle,
                            size: 20.w,
                            color: Colors.green,
                          )
                  : null,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
