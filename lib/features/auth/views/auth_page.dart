import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../../../core/routing/app_router.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }
  
  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).register(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );
    }
  }
  
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }
  
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }
  
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }
  
  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    // Listen to auth state changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isRegistrationSuccess && !next.isAuthenticated) {
        // Redirect to login page with pre-filled credentials
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (route) => false,
          arguments: {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
        );
        // Clear the registration success flag
        ref.read(authControllerProvider.notifier).clearRegistrationSuccess();
      }
    });
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Hesap Oluştur',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Finans takip uygulamasına katılın',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Error Messages
                if (authState.errors.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hata',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...authState.errors.map((error) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $error',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Form Fields
                CustomTextField(
                  label: 'Ad',
                  hint: 'Adınızı girin',
                  controller: _nameController,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  validator: (value) => _validateRequired(value, 'Ad'),
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Soyad',
                  hint: 'Soyadınızı girin',
                  controller: _surnameController,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  validator: (value) => _validateRequired(value, 'Soyad'),
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'E-posta',
                  hint: 'ornek@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  validator: _validateEmail,
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Şifre',
                  hint: 'En az 6 karakter',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  validator: _validatePassword,
                ),
                
                const SizedBox(height: 20),
                
                CustomTextField(
                  label: 'Şifre Tekrarı',
                  hint: 'Şifrenizi tekrar girin',
                  controller: _passwordConfirmationController,
                  isPassword: true,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  validator: _validatePasswordConfirmation,
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: 'Hesap Oluştur',
                  onPressed: _register,
                  isLoading: authState.isLoading,
                  icon: Icons.person_add,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.login,
                        (route) => false,
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Zaten hesabınız var mı? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                        children: [
                          TextSpan(
                            text: 'Giriş Yap',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
