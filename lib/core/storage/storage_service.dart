import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static const String _tokenKey =
      'auth_token';

  static const String _userKey =
      'user_data';

  Future<StorageService> init() async {
    _prefs =
    await SharedPreferences.getInstance();

    return this;
  }

  Future<void> writeToken(
      String token,
      ) async {
    await _prefs.setString(
      _tokenKey,
      token,
    );
  }

  String? readToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> writeUser(
      String userDataJson,
      ) async {
    await _prefs.setString(
      _userKey,
      userDataJson,
    );
  }

  String? readUser() {
    return _prefs.getString(_userKey);
  }

  Future<void> removeUser() async {
    await _prefs.remove(_userKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}