import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/features/jobBooking/screens/six/choose_contact_type_screen.dart';
import 'package:repair_cms/features/jobBooking/widgets/bottom_buttons_group.dart';

class JobBookingDeviceSecurityScreen extends StatefulWidget {
  const JobBookingDeviceSecurityScreen({super.key});

  @override
  State<JobBookingDeviceSecurityScreen> createState() => JobBookingDeviceSecurityScreenState();
}

class JobBookingDeviceSecurityScreenState extends State<JobBookingDeviceSecurityScreen> {
  final TextEditingController _passwordController = TextEditingController();
  String selectedOption = '';
  List<Offset> patternPoints = [];
  List<int> connectedDots = [];
  bool isDrawing = false;

  // Pattern grid positions (3x3)
  final List<Offset> dotPositions = [
    const Offset(0, 0),
    const Offset(1, 0),
    const Offset(2, 0),
    const Offset(0, 1),
    const Offset(1, 1),
    const Offset(2, 1),
    const Offset(0, 2),
    const Offset(1, 2),
    const Offset(2, 2),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * .071 * 5,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(0)),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1, blurStyle: BlurStyle.outer)],
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF71788F),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                        ),
                      ),
                    ),

                    // Step indicator
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 42.w,
                        height: 42.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('5', style: AppTypography.fontSize24.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Question text
                    Text('Device Security', style: AppTypography.fontSize22, textAlign: TextAlign.center),

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Security options
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    _buildSecurityOption(
                      icon: Icons.security,
                      title: 'No Security',
                      isSelected: selectedOption == 'none',
                      onTap: () => setState(() => selectedOption = 'none'),
                    ),

                    SizedBox(height: 12.h),

                    _buildSecurityOption(
                      icon: Icons.lock,
                      title: 'Password',
                      isSelected: selectedOption == 'password',
                      onTap: () => setState(() => selectedOption = 'password'),
                    ),

                    SizedBox(height: 12.h),

                    _buildSecurityOption(
                      icon: Icons.pattern,
                      title: 'Security Pattern',
                      isSelected: selectedOption == 'pattern',
                      onTap: () => setState(() => selectedOption = 'pattern'),
                    ),

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Dynamic content based on selection
            if (selectedOption == 'password') ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _buildPasswordInput(),
                ),
              ),
            ] else if (selectedOption == 'pattern') ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _buildPatternInput(),
                ),
              ),
            ],

            // Spacer to push buttons to bottom
            const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
          ],
        ),
      ),
      // Sticky bottom navigation bar with keyboard handling
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 8.h : 8.h,
          left: 24.w,
          right: 24.w,
        ),
        child: BottomButtonsGroup(
          onPressed: () {
            // Use a post-frame callback to avoid the deactivated widget error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChooseContactTypeScreen()));
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade600, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppTypography.fontSize16.copyWith(
                  color: isSelected ? AppColors.primary : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: AppColors.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Enter device password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            style: AppTypography.fontSize16,
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(
              _passwordController.text.length.clamp(0, 12),
              (index) => Container(
                margin: EdgeInsets.only(right: 4.w),
                child: Icon(Icons.star, size: 16.sp, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInput() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Responsive pattern container centered horizontally
          Center(
            child: Container(
              width: 260.w,
              height: 260.h,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CustomPaint(
                painter: PatternPainter(
                  dotPositions: dotPositions,
                  connectedDots: connectedDots,
                  patternPoints: patternPoints,
                  containerSize: 260.w - 24.w, // Subtract padding
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      isDrawing = true;
                      _handlePatternTouch(details.localPosition, 260.w - 24.w);
                    });
                  },
                  onPanUpdate: (details) {
                    if (isDrawing) {
                      setState(() {
                        _handlePatternTouch(details.localPosition, 260.w - 24.w);
                      });
                    }
                  },
                  onPanEnd: (details) {
                    setState(() {
                      isDrawing = false;
                    });
                  },
                  child: Container(width: double.infinity, height: double.infinity, color: Colors.transparent),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          if (connectedDots.isNotEmpty)
            Text(
              'Pattern: ${connectedDots.map((dot) => dot + 1).join(' → ')}',
              style: AppTypography.fontSize14.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),

          if (connectedDots.isNotEmpty) SizedBox(height: 12.h),

          if (connectedDots.isNotEmpty)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    connectedDots.clear();
                    patternPoints.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                child: Text('Clear Pattern', style: AppTypography.fontSize12),
              ),
            ),
        ],
      ),
    );
  }

  void _handlePatternTouch(Offset position, double containerSize) {
    final double dotRadius = containerSize * 0.06; // adjust size as needed
    final double spacing = containerSize / 3;

    // Centering: each dot is at (col + 0.5) * spacing
    for (int i = 0; i < dotPositions.length; i++) {
      final pos = Offset((dotPositions[i].dx + 0.5) * spacing, (dotPositions[i].dy + 0.5) * spacing);

      // In _handlePatternTouch → check touch distance
      if ((position - pos).distance < dotRadius * 2) {
        if (!connectedDots.contains(i)) {
          connectedDots.add(i);
          patternPoints.add(position);
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

class PatternPainter extends CustomPainter {
  final List<Offset> dotPositions;
  final List<int> connectedDots;
  final List<Offset> patternPoints;
  final double containerSize;

  PatternPainter({
    required this.dotPositions,
    required this.connectedDots,
    required this.patternPoints,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A5568)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final connectedPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Correct spacing for 3x3 grid
    final double dotRadius = containerSize * 0.06;
    final double spacing = containerSize / 3;

    // Draw grid dots (centered)
    for (int i = 0; i < dotPositions.length; i++) {
      final pos = Offset((dotPositions[i].dx + 0.5) * spacing, (dotPositions[i].dy + 0.5) * spacing);

      canvas.drawCircle(pos, dotRadius, connectedDots.contains(i) ? connectedPaint : paint);
    }

    // Draw connecting lines
    if (connectedDots.length > 1) {
      for (int i = 0; i < connectedDots.length - 1; i++) {
        final startDot = dotPositions[connectedDots[i]];
        final endDot = dotPositions[connectedDots[i + 1]];

        final startPos = Offset((startDot.dx + 0.5) * spacing, (startDot.dy + 0.5) * spacing);
        final endPos = Offset((endDot.dx + 0.5) * spacing, (endDot.dy + 0.5) * spacing);

        canvas.drawLine(startPos, endPos, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
