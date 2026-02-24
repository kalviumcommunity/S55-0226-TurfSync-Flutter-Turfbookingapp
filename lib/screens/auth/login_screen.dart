import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';
import 'register_screen.dart';

/// Login screen with email/password authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success && authProvider.errorMessage != null) {
      ErrorDialog.showError(context, authProvider.errorMessage!);
      authProvider.clearError();
    }
    // Navigation is handled by auth state listener in app.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // ─── Logo / Title ───
                Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 48),

                // ─── Email Field ───
                CustomTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),

                // ─── Password Field ───
                CustomTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ─── Forgot Password ───
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Login Button ───
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return CustomButton(
                      text: AppStrings.login,
                      onPressed: _handleLogin,
                      isLoading: auth.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ─── Register Link ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        AppStrings.signUp,
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            hintText: 'you@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final success =
                    await authProvider.resetPassword(emailController.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  ErrorDialog.showSuccess(
                      context, 'Password reset email sent!');
                } else {
                  ErrorDialog.showError(
                      context, authProvider.errorMessage ?? 'Failed');
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
