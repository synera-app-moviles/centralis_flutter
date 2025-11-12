import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/di/service_locator.dart';
import '../../data/models/notification_model.dart';

/// Notifications page displaying all user notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final storage = sl<SecureStorageService>();
    final userId = await storage.getUserId();

    if (userId != null) {
      setState(() {
        _userId = userId;
      });

      if (mounted) {
        context.read<NotificationBloc>().add(NotificationLoadRequested(userId));
      }
    }
  }

  Future<void> _refreshNotifications() async {
    if (_userId != null) {
      context.read<NotificationBloc>().add(NotificationSyncRequested(_userId!));
    }
  }

  void _markAsRead(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(NotificationMarkAsRead(notification.id));
    }
  }

  void _markAllAsRead() {
    if (_userId != null) {
      context.read<NotificationBloc>().add(NotificationMarkAllAsRead(_userId!));
    }
  }

  void _deleteNotification(String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CentralisColors.secondary,
        title: const Text(
          'Eliminar notificación',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta notificación?',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationBloc>().add(
                NotificationDeleteRequested(notificationId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteAllNotifications() {
    if (_userId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CentralisColors.secondary,
        title: const Text(
          'Eliminar todas las notificaciones',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todas las notificaciones?',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationBloc>().add(
                NotificationDeleteAllRequested(_userId!),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CentralisColors.background,
      appBar: AppBar(
        backgroundColor: CentralisColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CentralisColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: CentralisColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: CentralisColors.onBackground),
            color: CentralisColors.secondary,
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'delete_all') {
                _deleteAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: CentralisColors.onBackground),
                    SizedBox(width: 8),
                    Text(
                      'Marcar todas como leídas',
                      style: TextStyle(color: CentralisColors.onBackground),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Eliminar todas',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: CentralisColors.primary,
              ),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar notificaciones',
                    style: TextStyle(
                      color: CentralisColors.onBackground.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: CentralisColors.onBackground.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshNotifications,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded || state is NotificationSyncing) {
            final notifications = state is NotificationLoaded
                ? state.notifications
                : (state as NotificationSyncing).notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: CentralisColors.onBackground.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(
                        color: CentralisColors.onBackground.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshNotifications,
              color: CentralisColors.primary,
              backgroundColor: CentralisColors.secondary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _markAsRead(notification),
                    onDelete: () => _deleteNotification(notification.id),
                  );
                },
              ),
            );
          }

          return const Center(
            child: Text(
              'Cargando notificaciones...',
              style: TextStyle(color: CentralisColors.onBackground),
            ),
          );
        },
      ),
    );
  }
}

/// Widget for displaying a single notification card
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getIconForPriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Icons.priority_high;
      case 'MEDIUM':
        return Icons.notifications_active;
      case 'LOW':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForPriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return CentralisColors.primary;
      default:
        return CentralisColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Ahora';
        }
        return 'Hace ${difference.inMinutes}m';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        color: notification.isRead
            ? CentralisColors.secondary.withOpacity(0.7)
            : CentralisColors.secondary,
        elevation: notification.isRead ? 0 : 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(
                  color: _getColorForPriority(notification.priority).withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getColorForPriority(notification.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForPriority(notification.priority),
                    color: _getColorForPriority(notification.priority),
                  ),
                ),
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
                                color: CentralisColors.onBackground,
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CentralisColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: CentralisColors.onBackground.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            notification.priority,
                            style: TextStyle(
                              color: _getColorForPriority(notification.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: CentralisColors.onBackground.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              color: CentralisColors.onBackground.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

