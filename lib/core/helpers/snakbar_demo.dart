import 'dart:ui';
import 'package:repair_cms/core/app_exports.dart';
import 'package:solar_icons/solar_icons.dart';

class SnackbarDemo extends StatelessWidget {
  final String message;
  final Widget? icon;
  const SnackbarDemo({super.key, required this.message, this.icon});

  void showCustomSnackbar(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CustomSnackbar(
        title: message,
        icon: icon,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Scaffold(
        appBar: AppBar(title: const Text('Custom Snackbar Demo')),
        body: Center(
          child: ElevatedButton(onPressed: () => showCustomSnackbar(context), child: const Text('Show Snackbar')),
        ),
      ),
    );
  }
}

class CustomSnackbar extends StatefulWidget {
  final String title;
  final VoidCallback onDismiss;
  final Widget? icon;

  const CustomSnackbar({super.key, required this.onDismiss, required this.title, this.icon});

  @override
  State<CustomSnackbar> createState() => _CustomSnackbarState();
}

class _CustomSnackbarState extends State<CustomSnackbar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragOffset = 0.0;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // accumulate upward drag only
                setState(() {
                  _dragOffset += details.delta.dy;
                  // limit dragging downward (positive) so snackbar can't be pushed down too far
                  if (_dragOffset > 60) _dragOffset = 60;
                });
              },
              onVerticalDragEnd: (details) {
                // if flicked up fast or dragged beyond threshold, dismiss
                final velocity = details.velocity.pixelsPerSecond.dy;
                if (velocity < -700 || _dragOffset < -50) {
                  _dismissSnackbar();
                } else {
                  // animate back to position
                  setState(() {
                    _dragOffset = 0.0;
                  });
                }
              },
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // drag handle / optional icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: widget.icon ?? Icon(SolarIconsOutline.infoCircle, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // close button
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _dismissSnackbar,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(Icons.close, size: 20, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _dismissSnackbar() {
    if (_dismissing) return;
    _dismissing = true;
    // animate slide out then call onDismiss
    _controller.reverse().then((_) {
      try {
        widget.onDismiss();
      } catch (_) {}
    });
  }
}
