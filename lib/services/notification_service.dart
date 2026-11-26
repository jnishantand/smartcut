import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  DateTime? _initTime;

  Future<void> initialize() async {
    _initTime = DateTime.now();

    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('User granted FCM permission: ${settings.authorizationStatus}');

    // 2. Create High Importance Android Channel for Heads-up Banner
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();
    }

    // 3. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        log("Notification tapped: ${response.payload}");
      },
    );

    // 4. Set Background Message Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Handle Foreground Messages from FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got FCM message in foreground: ${message.notification?.title}');
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'SmartCut Notification',
          body: message.notification!.body ?? '',
        );
      }
    });

    // 6. Listen to Firestore Broadcast Notifications in Real-time for Instant System Banner
    _startFirestoreNotificationListener();

    // 7. Get and save FCM Token
    await _saveDeviceToken();
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });
  }

  void _startFirestoreNotificationListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _notificationSubscription?.cancel();
      if (user != null) {
        bool isFirstSnapshot = true;

        _notificationSubscription = FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', whereIn: [user.uid, 'all'])
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          if (isFirstSnapshot) {
            isFirstSnapshot = false;
            return; // Ignore pre-existing notifications on initial login
          }

          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data != null) {
                showLocalNotification(
                  title: data['title'] ?? 'SmartCut Announcement',
                  body: data['body'] ?? '',
                );
              }
            }
          }
        });
      }
    });
  }

  Future<void> showLocalNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true),
    );

    await _localNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: platformDetails,
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
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmTokens': FieldValue.arrayUnion([token])
        }, SetOptions(merge: true));
        log("FCM Token saved to Firestore");
      } catch (e) {
        log("Error saving FCM token to Firestore: $e");
      }
    }
  }

  void dispose() {
    _notificationSubscription?.cancel();
  }
}
