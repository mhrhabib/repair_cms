import 'package:repair_cms/core/app_exports.dart';
import 'package:repair_cms/core/utils/label_formatter.dart';
import 'package:repair_cms/core/utils/widgets/custom_nav_button.dart';
import 'package:repair_cms/features/notifications/models/notificaiton_model.dart';
import 'package:solar_icons/solar_icons.dart';

class NotificationListItem extends StatefulWidget {
  final Notifications notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;
  final String Function(String?) formatDate;
  final Widget Function(Notifications) getIcon;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.formatDate,
    required this.getIcon,
  });

  @override
  State<NotificationListItem> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<NotificationListItem>
    with SingleTickerProviderStateMixin {
  bool _optimisticRead = false;
  bool _isMenuOpen = false;
  late AnimationController _menuController;
  late Animation<double> _expandAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isRead = (widget.notification.isRead ?? false) || _optimisticRead;
    final jobNo = widget.notification.jobNo ?? widget.notification.messageData?['jobNo']?.toString();

    return InkWell(
      // Disable ripple/highlight on parent so child's menu button won't show item effect
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: () {
        // Optimistically mark as read and call handler
        if (!(widget.notification.isRead ?? false)) {
          setState(() => _optimisticRead = true);
          widget.onMarkAsRead();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isRead ? AppColors.whiteColor : AppColors.kBg,
        ),
        child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widget.getIcon(widget.notification),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final data = LabelFormatter.notificationData(
                          widget.notification,
                        );
                        final title =
                            data?.title ??
                            LabelFormatter.formatLabel(
                              widget.notification.message ?? '',
                            );
                        final text = data?.text;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                            if (text != null && text != title) ...[
                              const SizedBox(height: 2),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  height: 1.3,
                                ),
                              ),
                            ],
                            if (jobNo != null && jobNo.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                jobNo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.formatDate(widget.notification.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              CustomNavButton(
                onPressed: _toggleMenu,
                icon: _isMenuOpen ? Icons.close : Icons.more_horiz,
                size: 20.sp,
                width: 38.w,
                height: 38.w,
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axis: Axis.horizontal,
            axisAlignment: 1.0,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                margin: EdgeInsets.only(right: 46.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.kBg,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isRead) ...[
                      CustomNavButton(
                        onPressed: () {
                          _toggleMenu();
                          widget.onMarkAsRead();
                        },
                        icon: SolarIconsOutline.checkCircle,
                        size: 18.sp,
                        width: 36.w,
                        height: 36.w,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    CustomNavButton(
                      onPressed: () {
                        _toggleMenu();
                        widget.onDelete();
                      },
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      size: 18.sp,
                      width: 36.w,
                      height: 36.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
