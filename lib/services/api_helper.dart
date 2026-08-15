import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/token_service.dart';
import '../controller/auth_controller.dart';

class ApiHelper {
  static Future<bool>? _refreshFuture;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  static Future<bool> _refreshTokenOnce() async {
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }

    final future = _performRefresh();

    _refreshFuture = future;

    try {
      return await future;
    } finally {
      _refreshFuture = null;
    }
  }

  static Future<bool> _performRefresh() async {
    try {
      final authController = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(
              AuthController(),
              permanent: true,
            );

      final refreshed = await authController.refreshToken();

      if (!refreshed) {
        print("[ApiHelper] Refresh failed");
        return false;
      }

      final newToken = await TokenService.getToken();

      if (newToken == null || newToken.isEmpty) {
        print("[ApiHelper] New Access Token is empty");
        return false;
      }

      print("[ApiHelper] Refresh successful");

      return true;
    } catch (e) {
      print("[ApiHelper] Refresh exception: $e");
      return false;
    }
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
        ? {
            "Accept": "application/json",
            "Content-Type": "application/json",
          }
        : await _getHeaders();

    final uri = Uri.parse(url);

    http.Response response;

    try {
      if (files != null && files.isNotEmpty) {
        final requestMultipart = http.MultipartRequest(
          method.toUpperCase(),
          uri,
        );

        requestMultipart.headers.addAll(headers);
        requestMultipart.headers.remove("Content-Type");

        body?.forEach((key, value) {
          requestMultipart.fields[key] = value.toString();
        });

        for (final file in files) {
          requestMultipart.files.add(
            await http.MultipartFile.fromPath(
              'images[]',
              file.path,
            ),
          );
        }

        final streamedResponse =
            await requestMultipart.send();

        response =
            await http.Response.fromStream(streamedResponse);
      } else {
        final encodedBody =
            body != null ? jsonEncode(body) : null;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(
              uri,
              headers: headers,
            );
            break;

          case 'PUT':
            response = await http.put(
              uri,
              headers: headers,
              body: encodedBody,
            );
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

      if (response.statusCode == 401 &&
          !isRetry &&
          !skipAuth) {
        print("[ApiHelper] 401 - Starting refresh");

        final refreshed = await _refreshTokenOnce();

        if (refreshed) {
          print(
            "[ApiHelper] Refresh successful - retrying request",
          );

          return await request(
            url,
            method: method,
            body: body,
            files: files,
            isRetry: true,
            skipAuth: skipAuth,
          );
        }

        print(
          "[ApiHelper] Refresh failed - Logout",
        );

        await TokenService.clearSessionData();

        Get.offAllNamed('/ww');

        return response;
      }

      return response;
    } catch (e) {
      print("[ApiHelper] Error: $e");
      rethrow;
    }
  }

  static Future<http.Response> postMaintenanceComplete(
    String url,
    Map<String, String> body,
    List<XFile> beforeImages,
    List<XFile> afterImages, {
    bool isRetry = false,
  }) async {
    final headers = await _getHeaders();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll(headers);
      request.headers.remove("Content-Type");

      request.fields.addAll(body);

      for (final file in beforeImages) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'before_images[]',
            file.path,
          ),
        );
      }

      for (final file in afterImages) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'after_images[]',
            file.path,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response =
          await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401 && !isRetry) {
        print(
          "[ApiHelper] Multipart 401 - Starting refresh",
        );

        final refreshed = await _refreshTokenOnce();

        if (refreshed) {
          return await postMaintenanceComplete(
            url,
            body,
            beforeImages,
            afterImages,
            isRetry: true,
          );
        }

        print(
          "[ApiHelper] Multipart refresh failed - Logout",
        );

        await TokenService.clearSessionData();

        Get.offAllNamed('/ww');

        return response;
      }

      return response;
    } catch (e, stackTrace) {
      print("========== Multipart Error ==========");
      print("URL: $url");
      print("ERROR: $e");
      print(stackTrace);

      rethrow;
    }
  }

  static Future<http.Response> get(String url) {
    return request(
      url,
      method: 'GET',
    );
  }

  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body, {
    bool skipAuth = false,
  }) {
    return request(
      url,
      method: 'POST',
      body: body,
      skipAuth: skipAuth,
    );
  }

  static Future<http.Response> postWithImages(
    String url,
    Map<String, dynamic> body,
    List<XFile> images,
  ) {
    return request(
      url,
      method: 'POST',
      body: body,
      files: images,
    );
  }

  static Future<http.Response> put(
    String url,
    Map<String, dynamic> body,
  ) {
    return request(
      url,
      method: 'PUT',
      body: body,
    );
  }

  static Future<http.Response> delete(
    String url, {
    Map<String, dynamic>? body,
  }) {
    return request(
      url,
      method: 'DELETE',
      body: body,
    );
  }
}