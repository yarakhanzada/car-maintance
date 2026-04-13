import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:senior_project/controller/notification_service.dart';
import 'package:senior_project/firebase_options.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:senior_project/view/Technician/TechnicianBottombar.dart';
import 'package:senior_project/view/Tow%20Trucker/DriverBottombar.dart';
import 'package:senior_project/view/client/ClientBottombar.dart';
import 'package:senior_project/view/client/SplashScreen.dart';
import 'package:senior_project/view/shared/ServiceStationScreen.dart';


Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();


  NotificationService.getDeviceToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
  getPages: [
    GetPage(name: "/splash", page: () => SplashScreen()),
        GetPage(name: "/client", page: () => ClientBottombar()),
        GetPage(name: "/driver", page: () => DriverBottombar()),
        GetPage(name: "/tech", page: () => TechnicianBottombar()),
          GetPage(
          name: "/ww",
          page: () => ServiceStationScreen(),
        ),
      ],
    );
  }
}
