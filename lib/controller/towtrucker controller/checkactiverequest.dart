import 'dart:convert';

import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';

Future<bool> checkActiveRequest(int serviceRequestId) async {
  try {
    final response = await ApiHelper.get(
      "${ApiConfig.baseUrl}/v1/driver/tow-requests/$serviceRequestId/check-active",
    );

    final body = jsonDecode(response.body);

    print("CHECK ACTIVE RESPONSE:");
    print(body);

    if (response.statusCode == 200 && body["status"] == 1) {
      return body["data"]["is_active"] == true;
    }

    return false;
  } catch (e) {
    print("CHECK ACTIVE ERROR: $e");
    return false;
  }
}
