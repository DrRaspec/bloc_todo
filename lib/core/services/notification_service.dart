import 'package:bloc_todo/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String todoReminderChannelId = 'todo_reminder_channel';
  static const String todoReminderChannelName = 'Todo Reminders';
  static const String todoReminderChannelDescription =
      'Notifications for todo task reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
        todoReminderChannelId,
        todoReminderChannelName,
        channelDescription: todoReminderChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

  static const DarwinNotificationDetails _darwinDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _darwinDetails,
  );

  Future<void> init() async {
    if (_isInitialized) return;

    await _configureLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createAndroidChannel();
    _isInitialized = true;

    AppLogger.i(
      'Notification service initialized',
      data: {'timezone': tz.local.name},
    );
  }

  Future<bool> requestNotificationPermission() async {
    await _ensureInitialized();

    if (kIsWeb) return false;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await androidPlugin?.requestNotificationsPermission() ?? false;

      case TargetPlatform.iOS:
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;

      case TargetPlatform.macOS:
        final macOSPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        return await macOSPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;

      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
    }
  }

  Future<void> showTodoNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _ensureInitialized();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleTodoReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(scheduledAt, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (!scheduledDate.isAfter(now)) {
      throw ArgumentError.value(
        scheduledAt,
        'scheduledAt',
        'Reminder must be scheduled in the future',
      );
    }

    final notificationsGranted = await requestNotificationPermission();
    if (!notificationsGranted) {
      throw StateError('Notification permission was denied');
    }

    final androidScheduleMode = await _androidScheduleMode();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
    );

    AppLogger.i(
      'Todo reminder scheduled',
      data: {
        'id': id,
        'scheduledAt': scheduledDate.toIso8601String(),
        'timezone': tz.local.name,
        'androidScheduleMode': androidScheduleMode.name,
      },
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    await _ensureInitialized();
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _plugin.cancelAll();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();

    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (error, stackTrace) {
      AppLogger.w(
        'Could not detect the device timezone; using UTC',
        data: {'error': error.toString()},
      );
      AppLogger.d(
        'Timezone detection stack trace',
        data: {'stackTrace': stackTrace.toString()},
      );
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _createAndroidChannel() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        todoReminderChannelId,
        todoReminderChannelName,
        description: todoReminderChannelDescription,
        importance: Importance.max,
      ),
    );
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final exactAlarmGranted =
        await androidPlugin?.requestExactAlarmsPermission() ?? false;

    return exactAlarmGranted
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.i(
      'Notification tapped',
      data: {
        'id': response.id,
        'payload': response.payload,
        'actionId': response.actionId,
      },
    );

    // TODO: Navigate to the todo details using response.payload.
  }
}
