import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("id");
  }

  static Future<void> saveID(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("refresh_token", token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("role", role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<void> saveActiveRequest(String requestData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getID();
    if (userId != null) {
      await prefs.setString("active_request_$userId", requestData);
    }
  }

  static Future<String?> getActiveRequest() async {
    final currentUserId = await getID();
    return getActiveRequestForUser(currentUserId);
  }

  static Future<String?> getActiveRequestForUser(String? userId) async {
    if (userId == null || userId.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("active_request_$userId");
  }

  static Future<void> clearActiveRequestForUser(String? userId) async {
    if (userId == null || userId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("active_request_$userId");
  }

  static Future<void> clearActiveRequestForCurrentUser() async {
    final currentUserId = await getID();
    await clearActiveRequestForUser(currentUserId);
  }

  static Future<void> clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("refresh_token");
    await prefs.remove("role");
    await prefs.remove("id");
  }

  static Future<void> clearToken() async {
    await clearSessionData();
  }
}
