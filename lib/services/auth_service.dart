import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/user_role.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';

/// Handles all Firebase Authentication operations.
/// This is the single source of truth for auth state.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user (null if not signed in).
  User? get currentUser => _auth.currentUser;

  /// Registers a new user with email/password and creates their Firestore profile.
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      // 1. Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      // 2. Update display name
      await user.updateDisplayName(fullName);

      // 3. Create user document in Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        role: role,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e.code), code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Signs in a user with email and password.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }

      // Fetch user profile from Firestore
      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e.code), code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Fetches a user's profile from Firestore.
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw const NotFoundException('User profile not found');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException('Failed to fetch user profile: ${e.toString()}');
    }
  }

  /// Updates the user's FCM token for push notifications.
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw FirestoreException('Failed to update FCM token: ${e.toString()}');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthError(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }
}
