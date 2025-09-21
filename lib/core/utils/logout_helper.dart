import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../routing/app_router.dart';

/// Helper class for handling logout functionality
class LogoutHelper {
  /// Performs logout and navigates to login page
  static Future<void> logout(BuildContext context, WidgetRef ref) async {
    // Close any open dialogs or modals
    Navigator.of(context).pop();
    
    // Perform logout
    await ref.read(authControllerProvider.notifier).logout();
    
    // Navigate to login page if context is still mounted
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    }
  }
}
