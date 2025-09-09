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
      print('OneSignal başlatılıyor...');
      
      // OneSignal'i başlat
      OneSignal.initialize(_appId);
      
      // Permission iste
      final permission = await OneSignal.Notifications.requestPermission(true);
      print('OneSignal permission: $permission');
      
      // Player ID'yi al
      _playerId = await OneSignal.User.getOnesignalId();
      print('OneSignal Player ID: $_playerId');
      
      _isInitialized = true;
      print('OneSignal başarıyla başlatıldı');
    } catch (e) {
      print('OneSignal başlatma hatası: $e');
      throw NotificationException('OneSignal başlatılamadı: $e');
    }
  }
  
  /// Mevcut player ID'yi döndürür
  String? get playerId => _playerId;
  
  /// Player ID'yi yeniden alır
  Future<String?> refreshPlayerId() async {
    try {
      print('OneSignal Player ID yenileniyor...');
      _playerId = await OneSignal.User.getOnesignalId();
      print('Yeni OneSignal Player ID: $_playerId');
      return _playerId;
    } catch (e) {
      print('OneSignal Player ID alma hatası: $e');
      throw NotificationException('Player ID alınamadı: $e');
    }
  }
  
  /// Kullanıcıya external user ID atar
  Future<void> setExternalUserId(String externalUserId) async {
    try {
      print('OneSignal External User ID ayarlanıyor: $externalUserId');
      await OneSignal.login(externalUserId);
      print('OneSignal External User ID başarıyla ayarlandı');
    } catch (e) {
      print('OneSignal External User ID ayarlama hatası: $e');
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
        print('Notification received: ${event.notification.title}');
      });
      
      OneSignal.Notifications.addClickListener((event) {
        // Notification clicked
        print('Notification clicked: ${event.notification.title}');
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