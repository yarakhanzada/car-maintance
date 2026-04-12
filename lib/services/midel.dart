import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:senior_project/main.dart';
import 'package:senior_project/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class midl extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {


    if (token != null && token != "null") {
      return const RouteSettings(name: "/client");
    }

    return null;
  }
}
