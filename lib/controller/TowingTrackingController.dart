import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:senior_project/controller/auth_controller.dart';
import 'package:senior_project/services/api_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/token_service.dart';

class TowingTrackingController {
  final Map<String, dynamic> requestData;
  IO.Socket? socket;

  bool isAccepted = false;
  Map<String, dynamic>? driverData;
  LatLng? towTruckLocation;
  List<LatLng> routePoints = [];
  LatLng userLocation = const LatLng(33.5138, 36.2765);

  StreamSubscription<Position>? positionStream;
  Function? onUpdate;

  late String customerId;
  late String driverId;

  TowingTrackingController({required this.requestData, this.onUpdate});

  Future<void> initLocationServices() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(position.latitude, position.longitude);

      positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position pos) {
            userLocation = LatLng(pos.latitude, pos.longitude);

            if (socket != null && socket!.connected) {
              socket!.emit('update_customer_location', {
                'customer_id': customerId,
                'driver_id': driverId,
                'latitude': userLocation.latitude,
                'longitude': userLocation.longitude,
              });
            }
            if (onUpdate != null) onUpdate!();
          });
    } catch (e) {
      print("Error in initLocationServices: $e");
    }
    if (onUpdate != null) onUpdate!();
  }

  Future<void> initSocket() async {
    try {
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());

      await authController.refreshToken();

      final token = await TokenService.getToken() ?? '';
      if (token.isEmpty) {
        print("⚠️ Token is empty. Cannot connect.");
        return;
      }

      final data = requestData.containsKey('data')
          ? requestData['data']
          : requestData;
      final serviceRequest = data['service_request'];

      customerId =
          (serviceRequest?['user_id'] ??
                  data['user_id'] ??
                  requestData['user_id'] ??
                  "0")
              .toString();
      driverId =
          (serviceRequest?['tow_truck_id'] ??
                  data['assigned_tow_truck_id'] ??
                  requestData['driver_id'] ??
                  "0")
              .toString();

      print('👤 Customer ID: $customerId, Driver ID: $driverId');

      if (socket != null) {
        socket!.disconnect();
        socket!.dispose();
      }

      socket = IO.io(
        ApiConfig.socketServerUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _setupSocketListeners();
      socket!.connect();
    } catch (e) {
      print("❌ Error in initSocket: $e");
    }
  }

  void _setupSocketListeners() {
    if (socket == null) return;

    socket!.onConnect((_) {
      print('🚀 Connected to Node.js Socket server');

      socket!.emit('subscribe_to_driver', {
        'customer_id': customerId,
        'driver_id': driverId,
      });
    });

    socket!.on('token_expired', (data) async {
      print('⏳ Token expired event received, updating token...');
      await updateTokenAndReconnect();
    });

    socket!.onConnectError((err) async {
      print('❌ Connect Error: $err');
      final errStr = err.toString().toLowerCase();

      if (errStr.contains('jwt expired') ||
          errStr.contains('401') ||
          errStr.contains('auth_error') ||
          errStr.contains('invalid or expired')) {
        print(
          '🔄 Token expired during socket connection, refreshing and reconnecting...',
        );
        await updateTokenAndReconnect();
      }
    });

    socket!.onError((err) => print('⚠️ Socket Error: $err'));

    socket!.on('driver_location_update', (data) {
      isAccepted = true;

      driverData = {
        'driver_name': data['driver_name'] ?? 'سائق السحب',
        'truck_model': data['truck_model'] ?? 'Tow Truck',
      };

      towTruckLocation = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );

      if (towTruckLocation != null) {
        updateRoute(towTruckLocation!);
      }

      if (onUpdate != null) onUpdate!();
    });

    socket!.on('tracking_ended', (data) {
      isAccepted = false;
      towTruckLocation = null;
      routePoints.clear();
      if (onUpdate != null) onUpdate!();
    });
  }

  Future<void> updateTokenAndReconnect() async {
    try {
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());

      await authController.refreshToken();
      final newToken = await TokenService.getToken() ?? '';

      if (newToken.isNotEmpty) {
        print("🔑 New Token retrieved: $newToken");

        if (socket != null) {
          if (socket!.connected) {
            socket!.disconnect();
          }
          socket!.dispose();
        }
        print("🚀 Sending Token to Socket: $newToken");
        socket = IO.io(
          ApiConfig.socketServerUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setAuth({'token': newToken})
              .build(),
        );

        _setupSocketListeners();
        socket!.connect();
        print("✅ Socket recreated and reconnected with the new token.");
      }
    } catch (e) {
      print("❌ Error updating token in socket: $e");
    }
  }

  Future<void> updateRoute(LatLng truckPos) async {
    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${ApiConfig.openRouteApiKey}&start=${truckPos.longitude},${truckPos.latitude}&end=${userLocation.longitude},${userLocation.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords =
            data['features'][0]['geometry']['coordinates'];
        routePoints = coords
            .map((c) => LatLng(c[1] as double, c[0] as double))
            .toList();
        if (onUpdate != null) onUpdate!();
      }
    } catch (e) {
      print("❌ Routing Error: $e");
    }
  }

  void dispose() {
    if (socket != null) {
      socket!.disconnect();
      socket!.dispose();
    }

    final stream = positionStream;
    positionStream = null;
    stream?.cancel();
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:senior_project/controller/auth_controller.dart';
// import 'package:senior_project/services/api_config.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import '../services/token_service.dart';

// class TowingTrackingController {
//   final Map<String, dynamic> requestData;
//   IO.Socket? socket;

//   bool isAccepted = false;
//   Map<String, dynamic>? driverData;
//   LatLng? towTruckLocation;
//   List<LatLng> routePoints = [];
//   LatLng userLocation = const LatLng(33.5138, 36.2765);

//   StreamSubscription<Position>? positionStream;
//   Function? onUpdate;

//   late String customerId;
//   late String driverId;

//   // إضافات للتحكم في استقرار الاتصال
//   int _retryCount = 0;
//   final int _maxRetries = 3;
//   bool _isRefreshing = false;

//   TowingTrackingController({required this.requestData, this.onUpdate});

//   Future<void> initLocationServices() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       userLocation = LatLng(position.latitude, position.longitude);

//       positionStream = Geolocator.getPositionStream(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 10,
//         ),
//       ).listen((Position pos) {
//         userLocation = LatLng(pos.latitude, pos.longitude);

//         if (socket != null && socket!.connected) {
//           // إرسال موقع الزبون للسيرفر (متوافق مع حدث السيرفر)
//           socket!.emit('update_customer_location', {
//             'customer_id': customerId,
//             'driver_id': driverId,
//             'latitude': userLocation.latitude,
//             'longitude': userLocation.longitude,
//           });
//         }
//         if (onUpdate != null) onUpdate!();
//       });
//     } catch (e) {
//       print("Error in initLocationServices: $e");
//     }
//     if (onUpdate != null) onUpdate!();
//   }

//   Future<void> initSocket() async {
//     try {
//       final authController = Get.isRegistered<AuthController>()
//           ? Get.find<AuthController>()
//           : Get.put(AuthController());

//       // يفضل تحديث التوكن قبل البدء لضمان الصلاحية
//       await authController.refreshToken();

//       final token = await TokenService.getToken() ?? '';
//       if (token.isEmpty) {
//         print("⚠️ Token is empty. Cannot connect.");
//         return;
//       }

//       final data = requestData.containsKey('data') ? requestData['data'] : requestData;
//       final serviceRequest = data['service_request'];

//       customerId = (serviceRequest?['customer_id'] ?? data['customer_id'] ?? requestData['customer_id'] ?? "0").toString();
//       driverId = (serviceRequest?['driver_id'] ?? data['driver_id'] ?? requestData['driver_id'] ?? "0").toString();

//       print('👤 Customer ID: $customerId, Driver ID: $driverId');

//       if (socket != null) {
//         socket!.disconnect();
//         socket!.dispose();
//       }

//       // التعديل: إضافة Bearer للتوكن ليتوافق مع logic السيرفر (rawToken.slice(7))
//       socket = IO.io(
//         ApiConfig.socketServerUrl,
//         IO.OptionBuilder()
//             .setTransports(['websocket'])
//             .disableAutoConnect()
//             .setAuth({'token': 'Bearer $token'}) 
//             .build(),
//       );

//       _setupSocketListeners();
//       socket!.connect();
//     } catch (e) {
//       print("❌ Error in initSocket: $e");
//     }
//   }

//   void _setupSocketListeners() {
//     if (socket == null) return;

//     socket!.onConnect((_) {
//       print('🚀 Connected to Node.js Socket server');
//       _retryCount = 0; // تصفير المحاولات عند الاتصال الناجح

//       socket!.emit('subscribe_to_driver', {
//         'customer_id': customerId,
//         'driver_id': driverId,
//       });
//     });

//     socket!.on('token_expired', (data) async {
//       print('⏳ Token expired event received, updating token...');
//       await updateTokenAndReconnect();
//     });

//     socket!.onConnectError((err) async {
//       print('❌ Connect Error: $err');
//       final errStr = err.toString().toLowerCase();

//       // التحقق من أخطاء الصلاحية لبدء التحديث التلقائي
//       if (errStr.contains('jwt expired') ||
//           errStr.contains('401') ||
//           errStr.contains('auth_error') ||
//           errStr.contains('invalid or expired')) {
//         print('🔄 Token error detected, refreshing...');
//         await updateTokenAndReconnect();
//       }
//     });

//     socket!.onError((err) => print('⚠️ Socket Error: $err'));

//     socket!.on('driver_location_update', (data) {
//       isAccepted = true;

//       driverData = {
//         'driver_name': data['driver_name'] ?? 'سائق السحب',
//         'truck_model': data['truck_model'] ?? 'Tow Truck',
//       };

//       towTruckLocation = LatLng(
//         (data['latitude'] as num).toDouble(),
//         (data['longitude'] as num).toDouble(),
//       );

//       if (towTruckLocation != null) {
//         updateRoute(towTruckLocation!);
//       }

//       if (onUpdate != null) onUpdate!();
//     });

//     // التعديل: استقبال حدث نهاية التتبع من السيرفر
//     socket!.on('tracking_ended', (data) {
//       print("🏁 Tracking session ended by server");
//       isAccepted = false;
//       towTruckLocation = null;
//       routePoints.clear();
//       if (onUpdate != null) onUpdate!();
//     });
//   }

//   Future<void> updateTokenAndReconnect() async {
//     // حماية من الدخول في حلقة لانهائية من التحديث
//     if (_isRefreshing || _retryCount >= _maxRetries) return;
    
//     _isRefreshing = true;
//     _retryCount++;

//     try {
//       final authController = Get.isRegistered<AuthController>()
//           ? Get.find<AuthController>()
//           : Get.put(AuthController());

//       await authController.refreshToken();
//       final newToken = await TokenService.getToken() ?? '';

//       if (newToken.isNotEmpty) {
//         print("🔑 New Token retrieved. Reconnecting attempt: $_retryCount");

//         if (socket != null) {
//           socket!.disconnect();
//           socket!.dispose();
//         }

//         socket = IO.io(
//           ApiConfig.socketServerUrl,
//           IO.OptionBuilder()
//               .setTransports(['websocket'])
//               .disableAutoConnect()
//               .setAuth({'token': 'Bearer $newToken'}) // استخدام Bearer هنا أيضاً
//               .build(),
//         );

//         _setupSocketListeners();
//         socket!.connect();
//       }
//     } catch (e) {
//       print("❌ Error updating token in socket: $e");
//     } finally {
//       _isRefreshing = false;
//     }
//   }

//   Future<void> updateRoute(LatLng truckPos) async {
//     final String url =
//         'https://api.openrouteservice.org/v2/directions/driving-car?api_key=${ApiConfig.openRouteApiKey}&start=${truckPos.longitude},${truckPos.latitude}&end=${userLocation.longitude},${userLocation.latitude}';

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
//         routePoints = coords
//             .map((c) => LatLng(c[1] as double, c[0] as double))
//             .toList();
//         if (onUpdate != null) onUpdate!();
//       }
//     } catch (e) {
//       print("❌ Routing Error: $e");
//     }
//   }

//   void dispose() {
//     if (socket != null) {
//       socket!.disconnect();
//       socket!.dispose();
//     }

//     final stream = positionStream;
//     positionStream = null;
//     stream?.cancel();
//   }
// }