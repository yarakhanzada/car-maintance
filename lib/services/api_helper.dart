import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/token_service.dart';
import '../controller/auth_controller.dart';

class ApiHelper {
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await TokenService.getToken();
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<http.Response> request(
    String url, {
    required String method,
    Map<String, dynamic>? body,
    List<XFile>? files,
    bool isRetry = false,
    bool skipAuth = false,
  }) async {
    final headers = skipAuth
        ? {"Accept": "application/json", "Content-Type": "application/json"}
        : await _getHeaders();

    final uri = Uri.parse(url);
    http.Response response;

    try {
      if (files != null && files.isNotEmpty) {
        var requestMultipart = http.MultipartRequest(method.toUpperCase(), uri);
        requestMultipart.headers.addAll(headers);
        requestMultipart.headers.remove("Content-Type");

        body?.forEach((key, value) {
          requestMultipart.fields[key] = value.toString();
        });

        for (var file in files) {
          requestMultipart.files.add(
            await http.MultipartFile.fromPath('images[]', file.path),
          );
        }
        var streamedResponse = await requestMultipart.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final encodedBody = body != null ? jsonEncode(body) : null;
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: encodedBody);
            break;
          case 'DELETE':
            response = await http.delete(
              uri,
              headers: headers,
              body: encodedBody,
            );
            break;
          default:
            response = await http.post(
              uri,
              headers: headers,
              body: encodedBody,
            );
        }
      }

      if (response.statusCode == 401 && !isRetry && !skipAuth) {
        print(" [ApiHelper] Unauthorized - Attempting Refresh...");

        final authController = Get.isRegistered<AuthController>()
            ? Get.find<AuthController>()
            : Get.put(AuthController(), permanent: true);

        bool refreshed = await authController.refreshToken();

        if (refreshed) {
          print(" [ApiHelper] Refresh Success - Retrying Request...");
          return await request(
            url,
            method: method,
            body: body,
            files: files,
            isRetry: true,
          );
        } else {
          print(" [ApiHelper] Refresh Failed - Logging out...");
          await TokenService.clearToken();
          Get.offAllNamed('/ww');
          return response;
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> get(String url) => request(url, method: 'GET');

  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body, {
    bool skipAuth = false,
  }) => request(url, method: 'POST', body: body, skipAuth: skipAuth);

  static Future<http.Response> postWithImages(
    String url,
    Map<String, dynamic> body,
    List<XFile> images,
  ) => request(url, method: 'POST', body: body, files: images);

  static Future<http.Response> put(String url, Map<String, dynamic> body) =>
      request(url, method: 'PUT', body: body);

  static Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? body,
  }) => request(url, method: 'DELETE', body: body);
}
