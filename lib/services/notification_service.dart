import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  log("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    // 2. Initialize Local Notifications (for foreground notifications)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // 3. Set Background Message Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        _showForegroundNotification(message);
      }
    });

    // 5. Handle App Opened from Terminated State
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    // 6. Handle App Opened from Background State
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message);
    });

    // 7. Get and save FCM Token
    await _saveDeviceToken();
    
    // Refresh token on change
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
       _saveTokenToFirestore(newToken);
    });
  }

  void _onSelectNotification(NotificationResponse notificationResponse) {
    // Handle foreground notification tap logic here
    log("Foreground notification tapped with payload: ${notificationResponse.payload}");
  }

  void _handleMessageTap(RemoteMessage message) {
    // Navigate based on message.data here
    log("Handling message tap: ${message.data}");
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<void> _saveDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      log("Error getting FCM token: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'fcmTokens': FieldValue.arrayUnion([token])
        }, SetOptions(merge: true));
        log("FCM Token saved to Firestore");
      } catch (e) {
        log("Error saving FCM token to Firestore: $e");
      }
    }
  }
}
