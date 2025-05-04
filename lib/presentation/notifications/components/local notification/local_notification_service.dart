import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../main.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Function(String?)? onNotificationClick;

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        navigatorKey.currentState?.pushNamed(response.payload!);
      }
    });
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      'Your Account is Created Successfully!!',
      htmlFormatBigText: true,
      contentTitle: 'Welcome to Hairvana',
      htmlFormatContentTitle: true,
      summaryText: 'Shop Owner Account',
      htmlFormatSummaryText: true,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigTextStyleInformation,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);
  }
}
