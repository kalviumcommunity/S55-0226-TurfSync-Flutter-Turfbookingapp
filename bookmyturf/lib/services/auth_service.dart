import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  String? _userName;
  String? _teamName;
  String? get userName => _userName;
  String? get teamName => _teamName;

  AuthService() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userName = null;
        _teamName = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _userName = data['name'] ?? currentUser?.displayName ?? 'User';
        _teamName = data['teamName'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String teamName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);

      // Save user to Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'teamName': teamName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _userName = name;
      _teamName = teamName;
      notifyListeners();
      return null; // no error
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
