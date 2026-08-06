import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:senior_project/controller/midleController.dart';

class SplashScreen extends StatelessWidget {
  final controller = Get.put(Midlecontroller());

 SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      controller.checkLogin();
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}