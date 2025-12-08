import 'package:repair_cms/core/app_exports.dart';

class PatternInputWidget extends StatefulWidget {
  final List<int> initialPattern;
  final Function(List<int>) onPatternChanged;

  const PatternInputWidget({super.key, required this.onPatternChanged, this.initialPattern = const []});

  @override
  PatternInputWidgetState createState() => PatternInputWidgetState();
}

class PatternInputWidgetState extends State<PatternInputWidget> {
  List<int> connectedDots = [];
  bool isDrawing = false;
  final List<Offset> dotPositions = const [
    Offset(0, 0),
    Offset(1, 0),
    Offset(2, 0),
    Offset(0, 1),
    Offset(1, 1),
    Offset(2, 1),
    Offset(0, 2),
    Offset(1, 2),
    Offset(2, 2),
  ];

  @override
  void initState() {
    super.initState();
    connectedDots = List.from(widget.initialPattern);
  }

  // This allows the parent (bottom sheet) to clear the pattern
  @override
  void didUpdateWidget(covariant PatternInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPattern != oldWidget.initialPattern && widget.initialPattern.isEmpty) {
      setState(() {
        connectedDots.clear();
      });
    }
  }

  void _handlePatternTouch(Offset position, double containerSize) {
    final double dotRadius = containerSize * 0.06;
    final double spacing = containerSize / 3;

    for (int i = 0; i < dotPositions.length; i++) {
      final pos = Offset((dotPositions[i].dx + 0.5) * spacing, (dotPositions[i].dy + 0.5) * spacing);
      if ((position - pos).distance < dotRadius * 2.5 && !connectedDots.contains(i)) {
        setState(() => connectedDots.add(i));
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260.w,
        height: 260.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: CustomPaint(
          painter: PatternPainter(dotPositions: dotPositions, connectedDots: connectedDots, containerSize: 260.w),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                isDrawing = true;
                connectedDots.clear(); // Start fresh on new touch
                _handlePatternTouch(details.localPosition, 260.w);
              });
            },
            onPanUpdate: (details) {
              if (isDrawing) {
                _handlePatternTouch(details.localPosition, 260.w);
              }
            },
            onPanEnd: (details) {
              setState(() => isDrawing = false);
              widget.onPatternChanged(connectedDots); // Notify parent of final pattern
            },
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the pattern grid
class PatternPainter extends CustomPainter {
  final List<Offset> dotPositions;
  final List<int> connectedDots;
  final double containerSize;

  PatternPainter({required this.dotPositions, required this.connectedDots, required this.containerSize});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final connectedDotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final double dotRadius = containerSize * 0.05;
    final double spacing = containerSize / 3;

    // Draw grid dots
    for (int i = 0; i < dotPositions.length; i++) {
      final pos = Offset((dotPositions[i].dx + 0.5) * spacing, (dotPositions[i].dy + 0.5) * spacing);
      dotPaint.color = connectedDots.contains(i) ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade400;
      canvas.drawCircle(pos, dotRadius, dotPaint);
      if (connectedDots.contains(i)) {
        canvas.drawCircle(pos, dotRadius * 0.5, connectedDotPaint);
      }
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
