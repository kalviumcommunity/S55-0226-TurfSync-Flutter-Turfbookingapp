import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/turf_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/turf_repository.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/notification_service.dart';
import 'services/session_service.dart';
import 'services/turf_service.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message silently.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase
  await Firebase.initializeApp();

  // 2. FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Local Notifications
  await NotificationService().initialize();

  // 4. Services
  final authService = AuthService();
  final turfService = TurfService();
  final bookingService = BookingService();
  final sessionService = SessionService();

  // 5. Repositories
  final authRepo = AuthRepository(authService: authService);
  final turfRepo = TurfRepository(turfService: turfService);
  final bookingRepo = BookingRepository(bookingService: bookingService);
  final sessionRepo = SessionRepository(sessionService: sessionService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(authRepository: authRepo)),
        ChangeNotifierProvider(
            create: (_) => TurfProvider(turfRepository: turfRepo)),
        ChangeNotifierProvider(
            create: (_) => BookingProvider(bookingRepository: bookingRepo)),
        ChangeNotifierProvider(
            create: (_) => SessionProvider(sessionRepository: sessionRepo)),
      ],
      child: const TurfSyncApp(),
    ),
  );
}
