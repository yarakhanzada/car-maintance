import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/fcmtokenController.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> getDeviceToken() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      String? token = await _messaging.getToken();

      if (token != null) {
        print("**********************************************");
        print(" SUCCESS! Your Device Token is:");
        print(token);
        print("**********************************************");
        final fcmController = Get.put(FcmController());
        await fcmController.updateDeviceToken(token);
      }
    } catch (e) {
      print(" خطأ في جلب التوكن: $e");

      if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
        print(" جاري إعادة محاولة الاتصال بسيرفرات Firebase...");
        await Future.delayed(const Duration(seconds: 10));
        return getDeviceToken();
      }
    }
  }

  /// تهيئة الخدمة وطلب الأذونات
  static Future<void> init() async {
    // 1. طلب الإذن من المستخدم
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print(' تم منح إذن الإشعارات من قبل المستخدم');
    }

    // 2. إعدادات الأندرويد (أيقونة التطبيق)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 3. تشغيل مكتبة الإشعارات المحلية
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print(" تم الضغط على الإشعار: ${response.payload}");
      },
    );

    // 4. تفعيل مستمعي الأحداث
    _setupHandlers();
  }

  static void _setupHandlers() {
    //   التطبيق مفتوح أمام المستخدم
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(" وصل إشعار جديد (والتطبيق مفتوح):");
      print("العنوان: ${message.notification?.title}");

      _showLocalNotification(message);
    });

    //  التطبيق في الخلفية وتم الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🚀 تم فتح التطبيق عبر الضغط على الإشعار!");
      print("بيانات الإشعار (Data): ${message.data}");
    });
  }

  /// عرض الإشعار
  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      print(" محاولة إظهار التنبيه المنبثق على الشاشة...");

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
}
