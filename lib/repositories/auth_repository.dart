import '../core/enums/user_role.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Repository layer for authentication operations.
/// Abstracts the AuthService from the presentation layer.
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Currently signed-in Firebase user.
  User? get currentUser => _authService.currentUser;

  /// Register a new user.
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    return await _authService.registerWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  /// Sign in with email & password.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// Fetch user profile from Firestore.
  Future<UserModel> getUserProfile(String uid) async {
    return await _authService.getUserProfile(uid);
  }

  /// Update FCM token.
  Future<void> updateFcmToken(String uid, String token) async {
    await _authService.updateFcmToken(uid, token);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Reset password.
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
