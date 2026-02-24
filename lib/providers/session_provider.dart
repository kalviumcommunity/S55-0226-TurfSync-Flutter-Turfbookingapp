import 'dart:async';
import 'package:flutter/material.dart';
import '../models/practice_session_model.dart';
import '../core/errors/app_exceptions.dart';
import '../repositories/session_repository.dart';

/// Manages practice session state and operations.
class SessionProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository;

  SessionProvider({SessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository ?? SessionRepository();

  // ─── State ───
  List<PracticeSessionModel> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  StreamSubscription? _sessionsSubscription;

  // ─── Getters ───
  List<PracticeSessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Subscribes to all active sessions.
  void listenToSessions() {
    _setLoading(true);
    _sessionsSubscription?.cancel();
    _sessionsSubscription = _sessionRepository.getSessionsStream().listen(
      (sessions) {
        _sessions = sessions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load sessions';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Subscribes to sessions created by a specific coach.
  void listenToCoachSessions(String coachId) {
    _setLoading(true);
    _sessionsSubscription?.cancel();
    _sessionsSubscription =
        _sessionRepository.getCoachSessionsStream(coachId).listen(
      (sessions) {
        _sessions = sessions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load your sessions';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Creates a new session.
  Future<bool> createSession(PracticeSessionModel session) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _sessionRepository.createSession(session);
      _successMessage = 'Session created successfully!';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create session';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Player joins a session.
  Future<bool> joinSession(String sessionId, String playerId) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _sessionRepository.joinSession(sessionId, playerId);
      _successMessage = 'Successfully joined the session!';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to join session';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Player leaves a session.
  Future<bool> leaveSession(String sessionId, String playerId) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _sessionRepository.leaveSession(sessionId, playerId);
      _successMessage = 'Left the session';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to leave session';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing session (Coach only).
  Future<bool> updateSession(PracticeSessionModel session) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _sessionRepository.updateSession(session);
      _successMessage = 'Session updated successfully!';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update session';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a session (Coach only).
  Future<bool> deleteSession(String sessionId) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _sessionRepository.deleteSession(sessionId);
      _successMessage = 'Session deleted';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete session';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Alias for [clearMessages] for consistency.
  void clearError() => clearMessages();

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
