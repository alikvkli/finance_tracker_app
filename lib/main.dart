import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  
  // OneSignal'i başlat
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
  
  // OneSignal'in tam olarak yüklenmesi için kısa bir bekleme
  await Future.delayed(const Duration(seconds: 2));
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = getIt<StorageService>();
    
    // Determine initial route based on app state
    String initialRoute;
    if (storageService.isUserLoggedIn()) {
      // User is already logged in, go to dashboard
      initialRoute = AppRouter.dashboard;
    } else if (storageService.isOnboardingCompleted()) {
      // Onboarding completed but not logged in, go to login
      initialRoute = AppRouter.login;
    } else {
      // First time user, show onboarding
      initialRoute = AppRouter.onboarding;
    }
    
    return MaterialApp(
      title: 'Finance Tracker',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: initialRoute,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('tr', 'TR'),
      debugShowCheckedModeBanner: false,
    );
  }
}
