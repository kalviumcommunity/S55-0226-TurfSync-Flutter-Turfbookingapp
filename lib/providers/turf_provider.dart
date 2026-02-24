import 'package:flutter/material.dart';
import '../models/turf_model.dart';
import '../repositories/turf_repository.dart';
import '../core/errors/app_exceptions.dart';

/// Manages turf state and exposes turf operations to the UI.
class TurfProvider extends ChangeNotifier {
  final TurfRepository _turfRepository;

  TurfProvider({TurfRepository? turfRepository})
      : _turfRepository = turfRepository ?? TurfRepository();

  // ─── State ───
  List<TurfModel> _turfs = [];
  TurfModel? _selectedTurf;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ───
  List<TurfModel> get turfs => _turfs;
  TurfModel? get selectedTurf => _selectedTurf;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Subscribes to real-time turf updates.
  void listenToTurfs() {
    _setLoading(true);
    _turfRepository.getTurfsStream().listen(
      (turfs) {
        _turfs = turfs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load turfs';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Creates a new turf (Admin).
  Future<bool> createTurf(TurfModel turf) async {
    _setLoading(true);
    _clearError();
    try {
      await _turfRepository.createTurf(turf);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create turf';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing turf.
  Future<bool> updateTurf(TurfModel turf) async {
    _setLoading(true);
    _clearError();
    try {
      await _turfRepository.updateTurf(turf);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update turf';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Soft-deletes a turf.
  Future<bool> deleteTurf(String turfId) async {
    _setLoading(true);
    _clearError();
    try {
      await _turfRepository.deleteTurf(turfId);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete turf';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Selects a turf for detail/booking view.
  void selectTurf(TurfModel turf) {
    _selectedTurf = turf;
    notifyListeners();
  }

  /// Clears selected turf.
  void clearSelectedTurf() {
    _selectedTurf = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
