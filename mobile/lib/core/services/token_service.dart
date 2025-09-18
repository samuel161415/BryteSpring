import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
