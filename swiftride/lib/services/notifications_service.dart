// lib/services/notifications_service.dart
import 'package:swiftride/services/api_service.dart';

class NotificationModel {
  final String id, type, title, body, createdAt;
  final bool   isRead;

  const NotificationModel({
    required this.id, required this.type, required this.title,
    required this.body, required this.createdAt, required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id:        j['id']?.toString()         ?? '',
    type:      j['type']?.toString()       ?? '',
    title:     j['title']?.toString()      ?? '',
    body:      j['body']?.toString()       ?? '',
    createdAt: j['created_at']?.toString() ?? '',
    isRead:    j['is_read'] as bool?       ?? false,
  );
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();
  final _api = ApiService.instance;

  Future<List<NotificationModel>> getNotifications() async {
    final data    = await _api.get('/notifications/');
    final results = (data is Map ? data['results'] : data) as List? ?? [];
    return results.map((j) => NotificationModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> markRead(String id)  async => _api.post('/notifications/$id/read/');
  Future<void> markAllRead()        async => _api.post('/notifications/read-all/');
}
