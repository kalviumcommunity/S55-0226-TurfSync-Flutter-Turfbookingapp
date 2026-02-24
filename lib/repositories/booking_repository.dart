import '../models/booking_model.dart';
import '../core/enums/booking_status.dart';
import '../services/booking_service.dart';

/// Repository layer for booking operations.
class BookingRepository {
  final BookingService _bookingService;

  BookingRepository({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  /// Create a new booking with double-booking prevention.
  Future<BookingModel> createBooking(BookingModel booking) async {
    return await _bookingService.createBooking(booking);
  }

  /// Update booking status (approve/reject).
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? rejectionReason,
  }) async {
    await _bookingService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }

  /// Cancel a booking and free the slot.
  Future<void> cancelBooking(String bookingId) async {
    await _bookingService.cancelBooking(bookingId);
  }

  /// Real-time stream of all bookings.
  Stream<List<BookingModel>> getAllBookingsStream() {
    return _bookingService.getAllBookingsStream();
  }

  /// Real-time stream of user's bookings.
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingService.getUserBookingsStream(userId);
  }

  /// Real-time stream of pending bookings.
  Stream<List<BookingModel>> getPendingBookingsStream() {
    return _bookingService.getPendingBookingsStream();
  }

  /// Real-time stream of booked slot keys for a turf on a date.
  Stream<List<String>> getBookedSlotsStream(String turfId, DateTime date) {
    return _bookingService.getBookedSlotsStream(turfId, date);
  }

  /// One-time fetch of bookings for a turf on a date.
  Future<List<BookingModel>> getBookingsForTurfOnDate(
    String turfId,
    DateTime date,
  ) async {
    return await _bookingService.getBookingsForTurfOnDate(turfId, date);
  }
}
