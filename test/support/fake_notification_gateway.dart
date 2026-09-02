import 'package:valizim/core/notifications/notification_gateway.dart';

/// Records what the scheduler asked the OS to do.
class FakeNotificationGateway implements NotificationGateway {
  final Map<int, ({DateTime at, String title, String body, String? payload})>
      scheduled = <int, ({DateTime at, String title, String body, String? payload})>{};
  final List<int> cancelled = <int>[];
  int cancelAllCount = 0;
  bool grantPermission = true;
  NotificationPermission status = NotificationPermission.notRequested;
  bool openedSettings = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    status = grantPermission
        ? NotificationPermission.granted
        : NotificationPermission.denied;
    return grantPermission;
  }

  @override
  Future<NotificationPermission> permissionStatus() async => status;

  @override
  Future<void> openSystemSettings() async => openedSettings = true;

  @override
  Future<void> schedule({
    required int id,
    required DateTime localDateTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    scheduled[id] =
        (at: localDateTime, title: title, body: body, payload: payload);
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduled.clear();
  }

  @override
  Future<Set<int>> pendingIds() async => scheduled.keys.toSet();
}
