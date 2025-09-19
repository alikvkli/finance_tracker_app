import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

@singleton
class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  int? getInt(String key) {
    return _prefs.getInt(key);
  }
  
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  Future<bool> clear() async {
    return await _prefs.clear();
  }
  
  // Auth specific methods
  Future<bool> saveAuthToken(String token) async {
    return await setString('auth_token', token);
  }
  
  String? getAuthToken() {
    return getString('auth_token');
  }
  
  Future<bool> saveUserEmail(String email) async {
    return await setString('user_email', email);
  }
  
  String? getUserEmail() {
    return getString('user_email');
  }
  
  Future<bool> saveUserPassword(String password) async {
    return await setString('user_password', password);
  }
  
  String? getUserPassword() {
    return getString('user_password');
  }
  
  Future<bool> saveUserData({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required int userId,
  }) async {
    await setString('user_name', name);
    await setString('user_surname', surname);
    await setString('user_email', email);
    await setString('user_phone', phone);
    await setInt('user_id', userId);
    return true;
  }
  
  String? getUserName() => getString('user_name');
  String? getUserSurname() => getString('user_surname');
  String? getUserPhone() => getString('user_phone');
  int? getUserId() => getInt('user_id');

  Future<bool> clearAuthData() async {
    await remove('auth_token');
    await remove('user_email');
    await remove('user_password');
    await remove('user_name');
    await remove('user_surname');
    await remove('user_phone');
    await remove('user_id');
    return true;
  }
  
  bool isOnboardingCompleted() {
    return getBool(AppConstants.onboardingCompletedKey) ?? false;
  }
  
  bool isUserLoggedIn() {
    return getAuthToken() != null;
  }
  
  Future<bool> clearAuthToken() async {
    return await remove('auth_token');
  }
}
