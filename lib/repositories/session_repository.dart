import '../models/practice_session_model.dart';
import '../services/session_service.dart';

/// Repository layer for practice session operations.
class SessionRepository {
  final SessionService _sessionService;

  SessionRepository({SessionService? sessionService})
      : _sessionService = sessionService ?? SessionService();

  /// Create a new session.
  Future<PracticeSessionModel> createSession(
      PracticeSessionModel session) async {
    return await _sessionService.createSession(session);
  }

  /// Update a session.
  Future<void> updateSession(PracticeSessionModel session) async {
    await _sessionService.updateSession(session);
  }

  /// Delete a session.
  Future<void> deleteSession(String sessionId) async {
    await _sessionService.deleteSession(sessionId);
  }

  /// Player joins a session.
  Future<void> joinSession(String sessionId, String playerId) async {
    await _sessionService.joinSession(sessionId, playerId);
  }

  /// Player leaves a session.
  Future<void> leaveSession(String sessionId, String playerId) async {
    await _sessionService.leaveSession(sessionId, playerId);
  }

  /// Real-time stream of all active sessions.
  Stream<List<PracticeSessionModel>> getSessionsStream() {
    return _sessionService.getSessionsStream();
  }

  /// Real-time stream of sessions by a specific coach.
  Stream<List<PracticeSessionModel>> getCoachSessionsStream(String coachId) {
    return _sessionService.getCoachSessionsStream(coachId);
  }
}
