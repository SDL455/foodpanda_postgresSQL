import 'package:flutter/material.dart';
import 'package:foodpanda/core/constants/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/notification_model.dart';

/// Card widget ສຳລັບສະແດງ notification ໃນ rider app
class RiderNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const RiderNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (notification.type) {
      case 'NEW_DELIVERY':
        iconData = Icons.delivery_dining;
        iconColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case 'DELIVERY_ASSIGNED':
        iconData = Icons.assignment_turned_in;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        break;
      case 'ORDER_CANCELLED':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      case 'PROMOTION':
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case 'CHAT_MESSAGE':
        iconData = Icons.chat_bubble;
        iconColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
        break;
      case 'SYSTEM':
        iconData = Icons.info;
        iconColor = Colors.grey;
        backgroundColor = Colors.grey.withOpacity(0.1);
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  String _formatTime(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'lo');
  }
}
