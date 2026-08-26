import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../data/model/event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  final Set<String> _sentTenMinuteAlerts = {};

  static const String channelId = 'events_channel_high';
  static const String channelName = 'Event Notifications & Alerts';
  static const String channelDesc = 'High priority live notifications for event updates, reminders, and registrations';

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {

        const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        await androidPlugin.createNotificationChannel(androidChannel);

        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Android Notification Permission Granted: $granted');
      }

      _isInitialized = true;
      debugPrint('NotificationService successfully initialized and channel created');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  NotificationDetails _getNotificationDetails({
    Importance importance = Importance.max,
    Priority priority = Priority.max,
  }) {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      enableLights: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  Future<void> showNewEventNotification(EventModel event) async {
    try {
      await init();
      final formattedTime = DateFormat('EEE, MMM d • h:mm a').format(event.startTime);
      final id = (event.id.hashCode.abs() % 90000) + 1000;

      await _notificationsPlugin.show(
        id: id,
        title: '🎉 New Event Added: ${event.title}',
        body: '📅 $formattedTime at ${event.location.isNotEmpty ? event.location : "Venue"}. Tap to view!',
        notificationDetails: _getNotificationDetails(),
        payload: event.id,
      );
      debugPrint('Triggered New Event Notification for: ${event.title}');
    } catch (e) {
      debugPrint('Error showing new event notification: $e');
    }
  }

  Future<void> showTenMinuteReminderNotification(EventModel event) async {
    if (_sentTenMinuteAlerts.contains(event.id)) return;
    _sentTenMinuteAlerts.add(event.id);

    try {
      await init();
      final id = (event.id.hashCode.abs() % 90000) + 2000;
      await _notificationsPlugin.show(
        id: id,
        title: '⏰ Event Starting in 10 Minutes!',
        body: '${event.title} is about to begin at ${event.location.isNotEmpty ? event.location : "the venue"}. Get ready!',
        notificationDetails: _getNotificationDetails(),
        payload: event.id,
      );
      debugPrint('Triggered 10-Min Reminder for: ${event.title}');
    } catch (e) {
      debugPrint('Error showing 10-minute reminder: $e');
    }
  }

  Future<void> showEventLiveNotification(EventModel event) async {
    try {
      await init();
      final id = (event.id.hashCode.abs() % 90000) + 3000;
      await _notificationsPlugin.show(
        id: id,
        title: '🔴 EVENT IS LIVE NOW: ${event.title}',
        body: 'The live stream & event has started. Join in now!',
        notificationDetails: _getNotificationDetails(),
        payload: event.id,
      );
      debugPrint('Triggered Live Event Notification for: ${event.title}');
    } catch (e) {
      debugPrint('Error showing live notification: $e');
    }
  }

  Future<void> showInterestedNotification(EventModel event) async {
    try {
      await init();
      final id = (event.id.hashCode.abs() % 90000) + 4000;
      await _notificationsPlugin.show(
        id: id,
        title: '⭐ Registration / Saved: ${event.title}',
        body: 'You are all set! We will send you a reminder 10 minutes before the event begins.',
        notificationDetails: _getNotificationDetails(),
        payload: event.id,
      );
      debugPrint('Triggered Interested/Registered Notification for: ${event.title}');
    } catch (e) {
      debugPrint('Error showing interested notification: $e');
    }
  }

  Future<void> showTestNotification() async {
    try {
      await init();
      await _notificationsPlugin.show(
        id: 99999,
        title: '🔔 Astro Converse Event Alert',
        body: 'Push Notification engine is active and working perfectly!',
        notificationDetails: _getNotificationDetails(),
      );
      debugPrint('Triggered Test Notification');
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  void checkAndTriggerUpcomingReminders(List<EventModel> events) {
    final now = DateTime.now();

    for (final event in events) {
      final difference = event.startTime.difference(now);

      if (!difference.isNegative && difference.inMinutes <= 10) {
        showTenMinuteReminderNotification(event);
      }
    }
  }
}
