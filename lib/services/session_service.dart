import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/practice_session_model.dart';
import '../core/errors/app_exceptions.dart';

/// Handles all Practice Session Firestore operations.
class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the sessions collection.
  CollectionReference get _sessionsRef => _firestore.collection('sessions');

  /// Creates a new practice session (Coach only).
  Future<PracticeSessionModel> createSession(
      PracticeSessionModel session) async {
    try {
      final docRef = await _sessionsRef.add(session.toFirestore());
      return session.copyWith(id: docRef.id);
    } catch (e) {
      throw FirestoreException('Failed to create session: ${e.toString()}');
    }
  }

  /// Updates an existing session.
  Future<void> updateSession(PracticeSessionModel session) async {
    try {
      await _sessionsRef.doc(session.id).update(session.toFirestore());
    } catch (e) {
      throw FirestoreException('Failed to update session: ${e.toString()}');
    }
  }

  /// Deletes a session.
  Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionsRef.doc(sessionId).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete session: ${e.toString()}');
    }
  }

  /// Player joins a session (adds their UID to joinedPlayerIds).
  Future<void> joinSession(String sessionId, String playerId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _sessionsRef.doc(sessionId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const NotFoundException('Session not found');
        }

        final session = PracticeSessionModel.fromFirestore(doc);

        if (session.isFull) {
          throw const AppException('Session is already full');
        }

        if (session.hasPlayerJoined(playerId)) {
          throw const AppException('You have already joined this session');
        }

        final updatedPlayerIds = [...session.joinedPlayerIds, playerId];

        transaction.update(docRef, {
          'joinedPlayerIds': updatedPlayerIds,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException('Failed to join session: ${e.toString()}');
    }
  }

  /// Player leaves a session.
  Future<void> leaveSession(String sessionId, String playerId) async {
    try {
      await _sessionsRef.doc(sessionId).update({
        'joinedPlayerIds': FieldValue.arrayRemove([playerId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw FirestoreException('Failed to leave session: ${e.toString()}');
    }
  }

  /// Real-time stream of all active sessions.
  Stream<List<PracticeSessionModel>> getSessionsStream() {
    return _sessionsRef
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PracticeSessionModel.fromFirestore(doc))
            .toList());
  }

  /// Real-time stream of sessions created by a specific coach.
  Stream<List<PracticeSessionModel>> getCoachSessionsStream(String coachId) {
    return _sessionsRef
        .where('coachId', isEqualTo: coachId)
        .where('isActive', isEqualTo: true)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PracticeSessionModel.fromFirestore(doc))
            .toList());
  }
}
