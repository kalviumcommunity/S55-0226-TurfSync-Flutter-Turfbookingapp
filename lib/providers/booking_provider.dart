import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../core/enums/booking_status.dart';
import '../core/errors/app_exceptions.dart';
import '../repositories/booking_repository.dart';

/// Manages booking state and exposes booking operations to the UI.
class BookingProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;

  BookingProvider({BookingRepository? bookingRepository})
      : _bookingRepository = bookingRepository ?? BookingRepository();

  // ─── State ───
  List<BookingModel> _bookings = [];
  List<BookingModel> _pendingBookings = [];
  List<String> _bookedSlotKeys = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  DateTime _selectedDate = DateTime.now();

  // ─── Stream subscriptions ───
  StreamSubscription? _bookingsSubscription;
  StreamSubscription? _pendingSubscription;
  StreamSubscription? _slotsSubscription;

  // ─── Getters ───
  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get pendingBookings => _pendingBookings;
  List<String> get bookedSlotKeys => _bookedSlotKeys;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DateTime get selectedDate => _selectedDate;

  /// Sets the selected date for calendar view.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Checks if a slot key is already booked.
  bool isSlotBooked(String slotKey) => _bookedSlotKeys.contains(slotKey);

  /// Subscribes to bookings for all users (Admin).
  void listenToAllBookings() {
    _setLoading(true);
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _bookingRepository.getAllBookingsStream().listen(
      (bookings) {
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load bookings';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Subscribes to bookings for a specific user.
  void listenToUserBookings(String userId) {
    _setLoading(true);
    _bookingsSubscription?.cancel();
    _bookingsSubscription =
        _bookingRepository.getUserBookingsStream(userId).listen(
      (bookings) {
        _bookings = bookings;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load your bookings';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Subscribes to pending bookings (Admin approval queue).
  void listenToPendingBookings() {
    _pendingSubscription?.cancel();
    _pendingSubscription = _bookingRepository.getPendingBookingsStream().listen(
      (bookings) {
        _pendingBookings = bookings;
        notifyListeners();
      },
      onError: (error) {
        // Silently handle — pending list is supplementary
      },
    );
  }

  /// Subscribes to booked slots for a turf on the selected date.
  void listenToBookedSlots(String turfId, DateTime date) {
    _slotsSubscription?.cancel();
    _slotsSubscription =
        _bookingRepository.getBookedSlotsStream(turfId, date).listen(
      (slotKeys) {
        _bookedSlotKeys = slotKeys;
        notifyListeners();
      },
      onError: (error) {
        _bookedSlotKeys = [];
        notifyListeners();
      },
    );
  }

  /// Creates a new booking with double-booking prevention.
  Future<bool> createBooking(BookingModel booking) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _bookingRepository.createBooking(booking);
      _successMessage = 'Booking created successfully! Awaiting approval.';
      notifyListeners();
      return true;
    } on DoubleBookingException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create booking. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Approves a booking (Admin only).
  Future<bool> approveBooking(String bookingId) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _bookingRepository.updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.approved,
      );
      _successMessage = 'Booking approved successfully!';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to approve booking';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Rejects a booking (Admin only).
  Future<bool> rejectBooking(String bookingId, {String? reason}) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _bookingRepository.updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.rejected,
        rejectionReason: reason,
      );
      _successMessage = 'Booking rejected';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to reject booking';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cancels a booking.
  Future<bool> cancelBooking(String bookingId) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _bookingRepository.cancelBooking(bookingId);
      _successMessage = 'Booking cancelled';
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to cancel booking';
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
    _bookingsSubscription?.cancel();
    _pendingSubscription?.cancel();
    _slotsSubscription?.cancel();
    super.dispose();
  }
}
