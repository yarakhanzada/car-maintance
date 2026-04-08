import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 1. تأكد من وجود الاستيراد
import 'package:senior_project/controller/notification_service.dart';
import 'package:senior_project/firebase_options.dart';
import 'package:senior_project/view/shared/ServiceStationScreen.dart';

// معالج الخلفية (يجب أن يبقى خارج الكلاس)
Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  // انتظر 5 ثوانٍ حتى يستقر الإنترنت وخدمات الموقع قبل طلب التوكن
  NotificationService.getDeviceToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. يجب أن تكون GetMaterialApp وليس MaterialApp
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // العبارة التي تخفي الشريط الأحمر
      home: const ServiceStationScreen(), // الواجهة التي فيها الزر
    );
  }
}
