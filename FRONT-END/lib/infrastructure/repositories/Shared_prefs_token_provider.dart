import 'package:kuenteco/core/constants/Token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsTokenProvider implements TokenProvider {
  final SharedPreferences prefs;

  SharedPrefsTokenProvider(this.prefs);

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString('jwt_token', token);
  }

  @override
  Future<String?> getToken() async {
    return prefs.getString('jwt_token');
  }

  @override
  Future<void> clearToken() async {
    await prefs.remove('jwt_token');
  }
}
