import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/enums/user_role.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Manages authentication state across the app.
/// Provides the current user, auth status, and role-based access.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    // Listen to auth state changes on initialization
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  // ─── State ───
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // ─── Getters ───
  UserModel? get currentUser => _currentUser;
  UserModel? get userModel => _currentUser; // alias used by screens
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get currentRole => _currentUser?.role;
  String get userId => _currentUser?.uid ?? '';

  /// Called whenever Firebase auth state changes.
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } else {
      // Fetch user profile from Firestore
      try {
        _currentUser = await _authRepository.getUserProfile(firebaseUser.uid);
        _isAuthenticated = true;
      } catch (e) {
        _currentUser = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    }
  }

  /// Initializes auth state on app startup.
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final firebaseUser = _authRepository.currentUser;
      if (firebaseUser != null) {
        _currentUser = await _authRepository.getUserProfile(firebaseUser.uid);
        _isAuthenticated = true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user with email/password.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs in an existing user.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _errorMessage = 'Sign out failed';
    } finally {
      _setLoading(false);
    }
  }

  /// Sends password reset email.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authRepository.resetPassword(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates FCM token.
  Future<void> updateFcmToken(String token) async {
    if (_currentUser != null) {
      await _authRepository.updateFcmToken(_currentUser!.uid, token);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clears error message (e.g., after user dismisses it).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
