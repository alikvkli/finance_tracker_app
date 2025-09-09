# OneSignal Entegrasyonu Kurulum Rehberi

Bu rehber, Finance Tracker uygulamasında OneSignal push notification entegrasyonunun nasıl kurulacağını açıklar.

## 1. OneSignal Hesabı ve Uygulama Oluşturma

### OneSignal Hesabı Oluşturma
1. [OneSignal](https://onesignal.com/) sitesine gidin
2. Hesap oluşturun veya mevcut hesabınızla giriş yapın

### Yeni Uygulama Ekleme
1. OneSignal dashboard'ında "New App/Website" butonuna tıklayın
2. Uygulamanız için bir isim girin (örn: "Finance Tracker")
3. Platform olarak "Flutter" seçin

## 2. Platform Yapılandırması

### Android Yapılandırması

#### Firebase Projesi Oluşturma
1. [Firebase Console](https://console.firebase.google.com/) gidin
2. Yeni proje oluşturun
3. Android uygulamanızı projeye ekleyin
4. Package name: `com.example.finance_tracker_app`
5. `google-services.json` dosyasını `android/app/` klasörüne yerleştirin

#### OneSignal Android Ayarları
1. OneSignal dashboard'ında "Settings" > "Platforms" > "Google Android (FCM)" seçin
2. Firebase projenizden alacağınız bilgileri girin:
   - **Server Key**: Firebase Console > Project Settings > Cloud Messaging > Server key
   - **Sender ID**: Firebase Console > Project Settings > Cloud Messaging > Sender ID

#### Android Manifest Ayarları
`android/app/src/main/AndroidManifest.xml` dosyasına aşağıdaki izinleri ekleyin:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE"/>
```

#### Build.gradle Ayarları
`android/app/build.gradle` dosyasında `minSdkVersion`'ı en az 21 yapın:

```gradle
defaultConfig {
    minSdkVersion 21
    // diğer ayarlar...
}
```

### iOS Yapılandırması

#### Apple Developer Hesabı
1. Apple Developer hesabınızla [Apple Developer Console](https://developer.apple.com/) giriş yapın
2. Certificates, Identifiers & Profiles bölümüne gidin

#### Push Notification Certificate Oluşturma
1. "Keys" sekmesine gidin
2. "+" butonuna tıklayarak yeni key oluşturun
3. "Apple Push Notifications service (APNs)" seçin
4. Key'i indirin ve OneSignal'a yükleyin

#### OneSignal iOS Ayarları
1. OneSignal dashboard'ında "Settings" > "Platforms" > "Apple iOS" seçin
2. Oluşturduğunuz APNs key dosyasını yükleyin
3. Key ID ve Team ID bilgilerini girin

#### Info.plist Ayarları
`ios/Runner/Info.plist` dosyasına aşağıdaki anahtarları ekleyin:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>Bu uygulama push bildirimleri kullanır</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 3. OneSignal App ID'yi Yapılandırma

### App ID'yi Alma
1. OneSignal dashboard'ında "Settings" > "Keys & IDs" bölümüne gidin
2. "OneSignal App ID"yi kopyalayın

### Kodda App ID'yi Güncelleme
`lib/shared/services/notification_service.dart` dosyasında:

```dart
static const String _appId = 'YOUR_ONESIGNAL_APP_ID'; // Buraya kendi App ID'nizi yazın
```

## 4. Test Etme

### Test Bildirimi Gönderme
1. OneSignal dashboard'ında "Messages" > "New Push" tıklayın
2. Bildirim mesajınızı yazın
3. "Send to Test Device" seçin
4. Test cihazınızın Player ID'sini girin
5. "Send Message" tıklayın

### Player ID'yi Alma
Uygulamada player ID'yi görmek için:

```dart
final notificationService = getIt<NotificationService>();
final playerId = notificationService.playerId;
print('Player ID: $playerId');
```

## 5. Kullanım Örnekleri

### Login Sırasında External User ID Atama
```dart
// Auth controller'da otomatik olarak yapılıyor
await _notificationService.setExternalUserId(userId.toString());
```

### Logout Sırasında External User ID Kaldırma
```dart
// Auth controller'da otomatik olarak yapılıyor
await _notificationService.removeExternalUserId();
```

### Notification Listener'ları Ayarlama
```dart
final notificationService = getIt<NotificationService>();
notificationService.setupNotificationListeners();
```

## 6. Bildirim Gönderme (Backend)

Backend'den belirli bir kullanıcıya bildirim göndermek için OneSignal REST API kullanın:

```bash
curl --request POST \
  --url https://onesignal.com/api/v1/notifications \
  --header 'Authorization: Basic YOUR_REST_API_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "app_id": "YOUR_APP_ID",
    "include_external_user_ids": ["USER_ID"],
    "contents": {"en": "Merhaba! Yeni bir işlem eklendi."},
    "headings": {"en": "Finance Tracker"}
  }'
```

## 7. Sorun Giderme

### Yaygın Sorunlar

#### "App ID not found" Hatası
- OneSignal App ID'nin doğru girildiğinden emin olun
- App ID'de boşluk veya özel karakter olmadığından emin olun

#### Bildirimler Gelmiyor
- Cihazın internet bağlantısını kontrol edin
- Notification permission'ın verildiğinden emin olun
- Firebase yapılandırmasını kontrol edin (Android için)
- APNs certificate'ının doğru yüklendiğinden emin olun (iOS için)

#### Player ID null geliyor
- OneSignal'in düzgün initialize edildiğinden emin olun
- Permission'ın verildiğinden emin olun
- Birkaç saniye bekleyip tekrar deneyin

### Debug Modu
Debug bilgilerini görmek için:

```dart
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
```

## 8. Güvenlik Notları

- REST API Key'ini asla client-side kodda kullanmayın
- App ID public olabilir, ancak REST API Key gizli kalmalıdır
- Production ortamında debug mode'u kapatın

## 9. Daha Fazla Bilgi

- [OneSignal Flutter SDK Dokümantasyonu](https://documentation.onesignal.com/docs/flutter-sdk)
- [OneSignal REST API Dokümantasyonu](https://documentation.onesignal.com/reference)
- [Firebase Cloud Messaging Kurulumu](https://firebase.google.com/docs/cloud-messaging/flutter/client)
