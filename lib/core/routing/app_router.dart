import 'package:flutter/material.dart';

import '../../features/onboarding/views/onboarding_page.dart';
import '../../features/auth/views/auth_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/main/views/main_page.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );
      case login:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute(
          builder: (_) => LoginPage(
            preFilledEmail: args?['email'],
            preFilledPassword: args?['password'],
          ),
          settings: settings,
        );
      case home:
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialTab: 0),
          settings: settings,
        );
      case transactions:
        return MaterialPageRoute(
          builder: (_) => const MainPage(initialTab: 1),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );
    }
  }
}