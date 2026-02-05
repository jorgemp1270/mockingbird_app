import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // Get API base URL from shared preferences (no default, user must input)
  static Future<String?> getApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip');
  }

  // Default bucket name (matches the API default)
  static const String defaultBucket = 'mockingbird-storage-kris';
}
