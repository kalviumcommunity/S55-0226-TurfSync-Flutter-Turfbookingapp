import '../models/turf_model.dart';
import '../services/turf_service.dart';

/// Repository layer for turf management.
class TurfRepository {
  final TurfService _turfService;

  TurfRepository({TurfService? turfService})
      : _turfService = turfService ?? TurfService();

  /// Create a new turf.
  Future<TurfModel> createTurf(TurfModel turf) async {
    return await _turfService.createTurf(turf);
  }

  /// Update an existing turf.
  Future<void> updateTurf(TurfModel turf) async {
    await _turfService.updateTurf(turf);
  }

  /// Soft-delete a turf.
  Future<void> deleteTurf(String turfId) async {
    await _turfService.deleteTurf(turfId);
  }

  /// Fetch a single turf by ID.
  Future<TurfModel> getTurfById(String turfId) async {
    return await _turfService.getTurfById(turfId);
  }

  /// Real-time stream of all active turfs.
  Stream<List<TurfModel>> getTurfsStream() {
    return _turfService.getTurfsStream();
  }

  /// One-time fetch of all active turfs.
  Future<List<TurfModel>> getAllTurfs() async {
    return await _turfService.getAllTurfs();
  }
}
