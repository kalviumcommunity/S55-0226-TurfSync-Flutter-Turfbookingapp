import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../core/enums/booking_status.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/date_utils.dart';

/// Handles all Booking-related Firestore operations.
/// Implements transaction-based double booking prevention.
class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to the bookings collection.
  CollectionReference get _bookingsRef => _firestore.collection('bookings');

  /// Creates a new booking using a Firestore transaction.
  /// This prevents double-booking by atomically checking if the slot is taken.
  ///
  /// Strategy:
  /// - Uses a separate `bookedSlots` collection with composite key documents
  /// - Document ID = "turfId_date_slotKey" (e.g., "abc123_2026-01-15_09:00-10:00")
  /// - Transaction reads the slot doc first; if it exists → slot is taken
  /// - If not → creates both the slot doc and the booking doc atomically
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final compositeKey = booking.compositeKey;
      final slotDocRef = _firestore.collection('bookedSlots').doc(compositeKey);

      // Run as a Firestore transaction to ensure atomicity
      return await _firestore.runTransaction<BookingModel>((transaction) async {
        // Step 1: Check if slot is already booked
        final slotDoc = await transaction.get(slotDocRef);

        if (slotDoc.exists) {
          // Slot is already taken — abort the transaction
          throw const DoubleBookingException();
        }

        // Step 2: Create the booking document
        final bookingDocRef = _bookingsRef.doc();
        final newBooking = booking.copyWith(id: bookingDocRef.id);

        // Step 3: Atomically write both documents
        transaction.set(bookingDocRef, newBooking.toFirestore());
        transaction.set(slotDocRef, {
          'bookingId': bookingDocRef.id,
          'turfId': booking.turfId,
          'userId': booking.userId,
          'date': Timestamp.fromDate(booking.date),
          'slotKey': booking.slotKey,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });

        return newBooking;
      });
    } on DoubleBookingException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException('Failed to create booking: ${e.toString()}');
    }
  }

  /// Updates a booking's status (Admin: approve/reject).
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? rejectionReason,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status.toFirestore(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }

      // If rejecting, also remove the bookedSlot to free it up
      if (status == BookingStatus.rejected) {
        final bookingDoc = await _bookingsRef.doc(bookingId).get();
        if (bookingDoc.exists) {
          final booking = BookingModel.fromFirestore(bookingDoc);
          await _firestore
              .collection('bookedSlots')
              .doc(booking.compositeKey)
              .delete();
        }
      }

      await _bookingsRef.doc(bookingId).update(updates);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException(
          'Failed to update booking status: ${e.toString()}');
    }
  }

  /// Cancels a booking and frees the slot.
  Future<void> cancelBooking(String bookingId) async {
    try {
      final bookingDoc = await _bookingsRef.doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw const NotFoundException('Booking not found');
      }

      final booking = BookingModel.fromFirestore(bookingDoc);

      // Remove the booked slot document to free it
      await _firestore
          .collection('bookedSlots')
          .doc(booking.compositeKey)
          .delete();

      // Delete the booking
      await _bookingsRef.doc(bookingId).delete();
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException('Failed to cancel booking: ${e.toString()}');
    }
  }

  /// Real-time stream of all bookings (Admin view).
  Stream<List<BookingModel>> getAllBookingsStream() {
    return _bookingsRef.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Real-time stream of bookings for a specific user.
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _bookingsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Real-time stream of pending bookings (Admin approval queue).
  Stream<List<BookingModel>> getPendingBookingsStream() {
    return _bookingsRef
        .where('status', isEqualTo: BookingStatus.pending.toFirestore())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  /// Fetches booked slot keys for a specific turf on a specific date.
  /// Used to show which slots are taken in the calendar view.
  Stream<List<String>> getBookedSlotsStream(String turfId, DateTime date) {
    final dateKey = AppDateUtils.toDateKey(date);
    // Query bookedSlots where turfId matches and date matches
    return _firestore
        .collection('bookedSlots')
        .where('turfId', isEqualTo: turfId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final docDate = (doc.data()['date'] as Timestamp?)?.toDate();
            if (docDate == null) return false;
            return AppDateUtils.toDateKey(docDate) == dateKey;
          })
          .map((doc) => doc.data()['slotKey'] as String)
          .toList();
    });
  }

  /// Gets bookings for a specific turf on a specific date (one-time fetch).
  Future<List<BookingModel>> getBookingsForTurfOnDate(
    String turfId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _bookingsRef
          .where('turfId', isEqualTo: turfId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch bookings: ${e.toString()}');
    }
  }
}
