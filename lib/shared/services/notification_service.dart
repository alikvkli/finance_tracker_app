import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:injectable/injectable.dart';

@singleton
class NotificationService {
  static const String _appId = 'c9dbc041-34da-468b-9a57-983922030241'; // OneSignal App ID'nizi buraya ekleyin
  
  bool _isInitialized = false;
  String? _playerId;
  
  /// OneSignal'i başlatır
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      
      // OneSignal'i başlat
      OneSignal.initialize(_appId);
      
      // Permission iste
      final permission = await OneSignal.Notifications.requestPermission(true);
      
      // Player ID'yi al
      _playerId = await OneSignal.User.getOnesignalId();
      
      _isInitialized = true;
    } catch (e) {
      throw NotificationException('OneSignal başlatılamadı: $e');
    }
  }
  
  /// Mevcut player ID'yi döndürür
  String? get playerId => _playerId;
  
  /// Player ID'yi yeniden alır
  Future<String?> refreshPlayerId() async {
    try {
      _playerId = await OneSignal.User.getOnesignalId();
      return _playerId;
    } catch (e) {
      throw NotificationException('Player ID alınamadı: $e');
    }
  }
  
  /// Kullanıcıya external user ID atar
  Future<void> setExternalUserId(String externalUserId) async {
    try {
      await OneSignal.login(externalUserId);
    } catch (e) {
      throw NotificationException('External user ID atanamadı: $e');
    }
  }
  
  /// External user ID'yi kaldırır
  Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
    } catch (e) {
      throw NotificationException('External user ID kaldırılamadı: $e');
    }
  }
  
  /// Push notification permission durumunu kontrol eder
  Future<bool> hasPermission() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      return false;
    }
  }
  
  /// Push notification permission ister
  Future<bool> requestPermission() async {
    try {
      return await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      return false;
    }
  }
  
  /// Notification event listener'ları ayarlar (basitleştirilmiş)
  void setupNotificationListeners() {
    try {
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        // Notification received in foreground
      });
    } catch (e) {
      print('Error setting up notification listeners: $e');
    }
  }
}

class NotificationException implements Exception {
  final String message;
  
  NotificationException(this.message);
  
  @override
  String toString() => 'NotificationException: $message';
}