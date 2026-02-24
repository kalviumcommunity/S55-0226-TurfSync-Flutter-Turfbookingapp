import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/turf_model.dart';
import '../core/errors/app_exceptions.dart';

/// Handles all Turf-related Firestore operations.
class TurfService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the turfs collection.
  CollectionReference get _turfsRef => _firestore.collection('turfs');

  /// Creates a new turf in Firestore (Admin only).
  Future<TurfModel> createTurf(TurfModel turf) async {
    try {
      final docRef = await _turfsRef.add(turf.toFirestore());
      return turf.copyWith(id: docRef.id);
    } catch (e) {
      throw FirestoreException('Failed to create turf: ${e.toString()}');
    }
  }

  /// Updates an existing turf.
  Future<void> updateTurf(TurfModel turf) async {
    try {
      await _turfsRef.doc(turf.id).update(turf.toFirestore());
    } catch (e) {
      throw FirestoreException('Failed to update turf: ${e.toString()}');
    }
  }

  /// Deletes a turf (soft delete by setting isActive to false).
  Future<void> deleteTurf(String turfId) async {
    try {
      await _turfsRef.doc(turfId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw FirestoreException('Failed to delete turf: ${e.toString()}');
    }
  }

  /// Fetches a single turf by ID.
  Future<TurfModel> getTurfById(String turfId) async {
    try {
      final doc = await _turfsRef.doc(turfId).get();
      if (!doc.exists) {
        throw const NotFoundException('Turf not found');
      }
      return TurfModel.fromFirestore(doc);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException('Failed to fetch turf: ${e.toString()}');
    }
  }

  /// Real-time stream of all active turfs.
  Stream<List<TurfModel>> getTurfsStream() {
    return _turfsRef
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TurfModel.fromFirestore(doc)).toList());
  }

  /// Fetches all active turfs (one-time).
  Future<List<TurfModel>> getAllTurfs() async {
    try {
      final snapshot = await _turfsRef
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => TurfModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch turfs: ${e.toString()}');
    }
  }
}
