import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/announcement_detail_screen.dart';
import '../widgets/page_route.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op: system tray already shows the notification while backgrounded.
}

class PushNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _tokenRegisteredThisSession = false;
  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> init(GlobalKey<NavigatorState> key) async {
    navigatorKey = key;
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'push_default',
      'Notifications',
      description: 'Announcements and harvest reminders',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);

    _initialized = true;
  }

  // Push notifications are a nice-to-have — failures here (missing Play
  // Services, transient FCM handshake errors, no network) must never block
  // login or app startup, so every step below is defensive.
  static Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('[PushNotificationService] requestPermission failed: $e');
      return false;
    }
  }

  static Future<void> registerToken() async {
    if (_tokenRegisteredThisSession) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiService.registerDeviceToken(token);
        _tokenRegisteredThisSession = true;
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        ApiService.registerDeviceToken(newToken).catchError((e) {
          debugPrint('[PushNotificationService] token refresh registration failed: $e');
        });
      });
    } catch (e) {
      debugPrint('[PushNotificationService] registerToken failed: $e');
    }
  }

  static void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _plugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_default',
          'Notifications',
          channelDescription: 'Announcements and harvest reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['type'],
    );
  }

  static Future<void> _handleTap(RemoteMessage message) async {
    final nav = navigatorKey?.currentState;
    if (nav == null) return;
    if (message.data['type'] == 'announcement') {
      final id = int.tryParse(message.data['announcement_id'] ?? '');
      if (id == null) return;
      try {
        final announcement = await ApiService.getAnnouncement(id);
        nav.push(FadeSlideRoute(
          page: AnnouncementDetailScreen(announcement: announcement),
        ));
      } catch (_) {
        // Announcement may have been deleted since the push was sent.
      }
    }
  }
}
