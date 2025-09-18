// File: notifications_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_model.dart';

class NotificationsPage extends StatelessWidget {
  final List<AppNotification> notifications;
  final Function(String) onMarkAsRead;
  final Function() onClearAll;

  const NotificationsPage({
    super.key,
    required this.notifications,
    required this.onMarkAsRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notifications',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (notifications.isNotEmpty)
              TextButton(
                onPressed: onClearAll,
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'You have $unreadCount unread notifications.',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24.0),
        if (notifications.isEmpty)
          const Center(
            heightFactor: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
        if (notifications.isNotEmpty)
          ...notifications.reversed.map((notification) => _buildNotificationItem(context, notification)),
      ],
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: notification.isRead ? Theme.of(context).cardColor : Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          Icons.alarm,
          color: notification.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          notification.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: notification.isRead ? Colors.grey : null),
        ),
        subtitle: Text(
          notification.message,
          style: TextStyle(color: notification.isRead ? Colors.grey : null),
        ),
        trailing: notification.isRead
            ? null
            : IconButton(
          icon: const Icon(Icons.mark_email_read_outlined),
          onPressed: () => onMarkAsRead(notification.id),
        ),
        onTap: () => onMarkAsRead(notification.id),
      ),
    );
  }
}