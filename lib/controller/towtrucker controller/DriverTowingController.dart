import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:senior_project/controller/towtrucker%20controller/DriverNavigationController.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:senior_project/services/api_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../services/token_service.dart';
import '../../utils/map_helper.dart';

class DriverTowingController extends GetxController {
  final Map<String, dynamic> requestData;
  IO.Socket? socket;

  LatLng driverLocation = const LatLng(33.5138, 36.2765);
  LatLng? customerLocation;
  List<LatLng> routePoints = [];

  StreamSubscription<Position>? positionStream;

  late String customerId;
  late String driverId;
  late String requestId;
  bool isConnected = false;
  bool isJobStarted = false;
  String? distanceToCustomer;
  String? estimatedTime;

  int currentStatusIndex = 0;
  final List<Map<String, dynamic>> statusSequence = [
    {
      "title": "بدء التوجه",
      "key": "tow_on_the_way",
      "icon": Icons.directions_car,
    },
    {
      "title": "وصلت للزبون",
      "key": "tow_arrived_at_customer",
      "icon": Icons.location_on,
    },
    {
      "title": "جاري السحب",
      "key": "tow_in_progress",
      "icon": Icons.local_shipping,
    },
    {
      "title": "العودة للورشة",
      "key": "tow_returning_to_workshop",
      "icon": Icons.home_repair_service,
    },
  ];

  DriverTowingController({required this.requestData});

  @override
  void onInit() {
    super.onInit();
    _extractIds();
    initLocationServices();
    initSocket();
  }

  void _extractIds() {
    final data = requestData.containsKey('data')
        ? requestData['data']
        : requestData;
    requestId = (data['id'] ?? data['towing_request']?['id'] ?? "0").toString();
    customerId =
        (data['user_id'] ??
                data['towing_request']?['service_request']?['user_id'] ??
                "0")
            .toString();
    driverId = (data['towing_request']?['tow_truck_id'] ?? "0").toString();

    String currentStatus = data['status'] ?? "";

    if (currentStatus == "tow_assigned") {
      isJobStarted = false;
      currentStatusIndex = 0;
    } else {
      isJobStarted = true;
      currentStatusIndex = statusSequence.indexWhere(
        (element) => element['key'] == currentStatus,
      );
      if (currentStatusIndex == -1) currentStatusIndex = 0;
    }
    if (data['towing_request']?['location'] != null) {
      customerLocation = LatLng(
        (data['towing_request']['location']['latitude'] as num).toDouble(),
        (data['towing_request']['location']['longitude'] as num).toDouble(),
      );
    }
    update();
  }

  Future<void> initLocationServices() async {
    _sendLocationToSocket();
    //  await updateDriverLocationAPI();
    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 10,
          ),
        ).listen((Position pos) async {
          if (pos.latitude == 0 && pos.longitude == 0) return;
          driverLocation = LatLng(pos.latitude, pos.longitude);
          _sendLocationToSocket();
          await updateDriverLocationAPI();
          _updateMapData();
        });
  }

  void _sendLocationToSocket() {
    if (socket != null && socket!.connected) {
      socket!.emit('towtrucklocationupdate', {
        'customer_id': customerId,
        'driver_id': driverId,
        'latitude': driverLocation.latitude,
        'longitude': driverLocation.longitude,
      });
    }
  }

  Future<void> _updateMapData() async {
    if (customerLocation == null) return;

    final data = await MapHelper.getRouteData(
      driverLocation,
      customerLocation!,
    );
    if (data != null) {
      distanceToCustomer = data['distance'];
      estimatedTime = data['duration'];
    }

    routePoints = await MapHelper.getPolylinePoints(
      driverLocation,
      customerLocation!,
    );
    update();
  }

  Future<void> initSocket() async {
    final token = await TokenService.getToken() ?? '';
    socket = IO.io(
      ApiConfig.socketServerUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .build(),
    );
    _setupSocketListeners();
    socket!.connect();
  }

  void _setupSocketListeners() {
    socket!.onConnect((_) {
      isConnected = true;
      socket!.emit('subscribe_to_customer', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
      update();
    });

    socket!.on('customer_location_update', (data) {
      customerLocation = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );
      _updateMapData();
    });

    socket!.on('tracking_ended', (data) async {
      final result = await completeTowingAPI();
      if (result == null) {
        final nav = Get.find<DriverNavigationController>();
        await nav.clearActiveOrder();
        Get.snackbar("نجاح", "تم إنهاء المهمة وإغلاق التتبع");
      }
      update();
    });

    socket!.on('tow_complete_rejected', (data) => _showRejectDialog(data));
    socket!.onDisconnect((_) => isConnected = false);
  }

  void _showRejectDialog(dynamic data) {
    int currentDist = data['current_distance_meters'] ?? 0;
    int maxDist = data['max_allowed_meters'] ?? 200;
    Get.defaultDialog(
      title: "تعذر إنهاء المهمة",
      titleStyle: const TextStyle(
        color: Color(0xFFE55757),
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          const Icon(Icons.location_off, size: 50, color: Color(0xFFE55757)),
          const SizedBox(height: 15),
          Text(
            data['message'] ?? "أنت بعيد جداً عن موقع الزبون",
            textAlign: TextAlign.center,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDistanceInfo("المسافة الحالية", "$currentDist م"),
              _buildDistanceInfo("النطاق المسموح", "$maxDist م"),
            ],
          ),
        ],
      ),
      textConfirm: "حسناً",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFE55757),
      onConfirm: () => Get.back(),
    );
  }

  Widget _buildDistanceInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void completeTowingViaSocket() {
    if (socket != null && socket!.connected) {
      socket!.emit('tow_completed', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
    }
  }

  @override
  void onClose() {
    positionStream?.cancel();
    socket?.dispose();
    super.onClose();
  }

  //______________________ --- APIS ---_________________________________
  //Start Towing API
  //Update Tow Status API
  //Complete Towing API

  // Future<bool> startTowing() async {
  //   final id =
  //       (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
  //           .toString();
  //   final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/start";

  //   try {
  //     final response = await ApiHelper.post(url, {
  //       "latitude": driverLocation.latitude,
  //       "longitude": driverLocation.longitude,
  //     });
  //     final decodedBody = utf8.decode(response.bodyBytes);

  //     print("Response status: ${response.statusCode}, body: $decodedBody");
  //     // if (response.statusCode == 200 || response.statusCode == 201) {
  //     //   isJobStarted = true;
  //     //   currentStatusIndex = 0;
  //     //   update();
  //     //   return true;
  //     // }
  //     if (response.statusCode == 200) {
  //       final body = jsonDecode(decodedBody);

  //       requestData.clear();

  //       requestData.addAll(body["data"]["towing_request"]["service_request"]);

  //       requestData["towing_request"] = body["data"]["towing_request"];

  //       GetStorage().write("active_order", requestData);

  //       Get.find<DriverNavigationController>().activeOrderData.value =
  //           requestData;

  //       _extractIds();

  //       update();

  //       return true;
  //     }
  //   } catch (e) {
  //     debugPrint("خطأ في بدء عملية السحب: $e");
  //   }
  //   return false;
  // }
  Future<String?> startTowing() async {
    final id =
        (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
            .toString();
    final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/start";

    try {
      final response = await ApiHelper.post(url, {
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      });
      final decodedBody = utf8.decode(response.bodyBytes);
      final body = jsonDecode(decodedBody);

      if (response.statusCode == 200) {
        requestData.clear();
        requestData.addAll(body["data"]["towing_request"]["service_request"]);
        requestData["towing_request"] = body["data"]["towing_request"];
        await TokenService.saveActiveRequest(
          jsonEncode(requestData),
          userId: driverId,
        );
        await Get.find<DriverNavigationController>().saveActiveOrder(
          requestData,
        );
        _extractIds();
        update();
        return null; // نجاح
      } else {
        return body['message'] ?? "فشل بدء المهمة";
      }
    } catch (e) {
      return "خطأ في الاتصال: $e";
    }
  }
  // Future<bool> updateTowStatusAPI(String status) async {
  //   final id =
  //       (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
  //           .toString();
  //   print(
  //     "Debug: Driver Loc: ${driverLocation.latitude}, ${driverLocation.longitude}",
  //   );
  //   print(
  //     "Debug: Customer Loc: ${customerLocation?.latitude}, ${customerLocation?.longitude}",
  //   );
  //   final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/status";
  //   print(
  //     "Updating tow status to '$status' at URL: $url with location (${driverLocation.latitude}, ${driverLocation.longitude})",
  //   );
  //   try {
  //     final response = await ApiHelper.post(url, {
  //       "status": status,
  //       "latitude": driverLocation.latitude,
  //       "longitude": driverLocation.longitude,
  //     });
  //     final decodedBody = utf8.decode(response.bodyBytes);
  //     print("Response status: ${response.statusCode}, body: $decodedBody");
  //     if (response.statusCode == 200) {
  //       int nextIndex = statusSequence.indexWhere(
  //         (element) => element['key'] == status,
  //       );
  //       if (nextIndex != -1) {
  //         //    currentStatusIndex = nextIndex;
  //         currentStatusIndex = nextIndex;

  //         requestData["status"] = status;

  //         GetStorage().write("active_order", requestData);

  //         Get.find<DriverNavigationController>().activeOrderData.value =
  //             requestData;

  //         update();
  //         update();
  //       }
  //       return true;
  //     }
  //   } catch (e) {
  //     debugPrint("خطأ في تحديث الحالة: $e");
  //   }
  //   return false;
  // }
  Future<String?> updateTowStatusAPI(String status) async {
    await updateDriverLocationAPI();
    final id =
        (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
            .toString();
    final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/status";

    try {
      final response = await ApiHelper.post(url, {
        "status": status,
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      });
      final decodedBody = utf8.decode(response.bodyBytes);
      final body = jsonDecode(decodedBody);

      if (response.statusCode == 200) {
        int nextIndex = statusSequence.indexWhere(
          (element) => element['key'] == status,
        );
        if (nextIndex != -1) {
          currentStatusIndex = nextIndex;
          requestData["status"] = status;
          await TokenService.saveActiveRequest(
            jsonEncode(requestData),
            userId: driverId,
          );
          await Get.find<DriverNavigationController>().saveActiveOrder(
            requestData,
          );
          update();
        }
        return null;
      } else {
        return body['message'] ?? "فشل تحديث الحالة";
      }
    } catch (e) {
      return "خطأ في الاتصال: $e";
    }
  }
  // Future<bool> completeTowingAPI() async {
  //   final id =
  //       (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
  //           .toString();
  //   final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/complete";

  //   try {
  //     final response = await ApiHelper.post(url, {
  //       "latitude": driverLocation.latitude,
  //       "longitude": driverLocation.longitude,
  //     });

  //     // return response.statusCode == 200;
  //     if (response.statusCode == 200) {
  //       GetStorage().remove("active_order");

  //       final nav = Get.find<DriverNavigationController>();
  //       nav.activeOrderData.value = null;

  //       nav.selectedIndex.value = 0;

  //       return true;
  //     }

  //     return false;
  //   } catch (e) {
  //     debugPrint("خطأ في إنهاء السحب: $e");
  //     return false;
  //   }
  // }
  Future<String?> completeTowingAPI() async {
    final id =
        (requestData['towing_request']?['id'] ?? requestData['id'] ?? requestId)
            .toString();
    final url = "${ApiConfig.baseUrl}/v1/driver/tow-requests/$id/complete";

    try {
      final response = await ApiHelper.post(url, {
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      });
      final decodedBody = utf8.decode(response.bodyBytes);
      final body = jsonDecode(decodedBody);

      if (response.statusCode == 200) {
        await TokenService.clearActiveRequestForUser(driverId);
        final nav = Get.find<DriverNavigationController>();
        await nav.clearActiveOrder();
        return null;
      } else {
        return body['message'] ?? "فشل إنهاء المهمة";
      }
    } catch (e) {
      return "خطأ في الاتصال: $e";
    }
  }

  Future<void> updateDriverLocationAPI() async {
    try {
      final serviceRequestId =
          requestData['id'] ??
          requestData['towing_request']?['service_request_id'] ??
          requestId;

      final body = {
        "service_request_id": serviceRequestId,
        "latitude": driverLocation.latitude,
        "longitude": driverLocation.longitude,
      };

      final response = await ApiHelper.post(
        "${ApiConfig.baseUrl}/v1/driver/location/update",
        body,
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      print("========== UPDATE DRIVER LOCATION ==========");
      print("URL: ${ApiConfig.baseUrl}/v1/driver/location/update");
      print("Request Body: $body");
      print("Status Code: ${response.statusCode}");
      print("Response Body: $decodedBody");
      print("===========================================");

      final jsonData = json.decode(decodedBody);
    } catch (e) {
      print("========== UPDATE DRIVER LOCATION ERROR ==========");
      print(e);
      print("=================================================");

      Get.snackbar("خطأ", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
