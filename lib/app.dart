import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/enums/user_role.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/dashboard/coach_dashboard.dart';
import 'screens/dashboard/player_dashboard.dart';
import 'widgets/common/loading_indicator.dart';

/// Root MaterialApp — routes depend on auth state.
class TurfSyncApp extends StatelessWidget {
  const TurfSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const _AuthGate(),
    );
  }
}

/// Listens to [AuthProvider] and routes accordingly.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProv, _) {
        // Still initialising / waiting for Firebase Auth state.
        if (authProv.isLoading && authProv.userModel == null) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Loading…'),
          );
        }

        // Not signed in.
        if (authProv.userModel == null) {
          return const LoginScreen();
        }

        // Signed in – route to role-specific dashboard.
        switch (authProv.userModel!.role) {
          case UserRole.admin:
            return const AdminDashboard();
          case UserRole.coach:
            return const CoachDashboard();
          case UserRole.player:
            return const PlayerDashboard();
        }
      },
    );
  }
}
