import 'dart:convert';
import 'package:senior_project/model/completed_service_model.dart';
import 'package:senior_project/services/api_config.dart';
import '../services/api_helper.dart';

class CompletedServicesController {
  
  Future<List<CompletedServiceModel>> fetchCompletedServices() async {
    try {
      final response = await ApiHelper.get("${ApiConfig.baseUrl}/customer/requests/completed");
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'];
        print("???????????????????????????????????????????????????????");
        print(jsonData);
        return dataList.map((item) => CompletedServiceModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> submitRating({required int requestId, required double rating, String? comment}) async {
    try {
      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/requests/$requestId/rate",
        {
          "rating": rating.toInt(),
          "comment": comment ?? "No comment",
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": data['message'] ?? "Rating submitted!"};
      } else {
        return {"success": false, "message": data['message'] ?? "You have already rated this service."};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }

  Future<Map<String, dynamic>> submitComplaint({required int requestId, required String complaintText}) async {
    try {
      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/customer/requests/$requestId/complain",
        {
          "complaint_text": complaintText,
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": data['message'] ?? "Complaint submitted!"};
      } else {
        return {"success": false, "message": data['message'] ?? "You have already filed a complaint."};
      }
    } catch (e) {
      return {"success": false, "message": "Connection error"};
    }
  }
}