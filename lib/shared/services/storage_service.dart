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
  
  Future<bool> clearAuthData() async {
    await remove('auth_token');
    await remove('user_email');
    await remove('user_password');
    return true;
  }
  
  bool isOnboardingCompleted() {
    return getBool(AppConstants.onboardingCompletedKey) ?? false;
  }
  
  bool isUserLoggedIn() {
    return getAuthToken() != null;
  }
}
