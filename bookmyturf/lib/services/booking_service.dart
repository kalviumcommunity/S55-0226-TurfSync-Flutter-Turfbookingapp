import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Turf> _turfs = [];
  List<TurfBooking> _myBookings = [];
  bool _isLoading = false;

  List<Turf> get turfs => _turfs;
  List<TurfBooking> get myBookings => _myBookings;
  bool get isLoading => _isLoading;

  // ── Turfs ──────────────────────────────────────────────

  Future<void> loadTurfs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('turfs').get();
      if (snapshot.docs.isEmpty) {
        // Seed initial turf data
        await _seedTurfs();
        final seeded = await _db.collection('turfs').get();
        _turfs = seeded.docs.map((d) => Turf.fromFirestore(d)).toList();
      } else {
        _turfs = snapshot.docs.map((d) => Turf.fromFirestore(d)).toList();
      }
    } catch (e) {
      debugPrint('Error loading turfs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedTurfs() async {
    final batch = _db.batch();
    for (final turf in seedTurfs) {
      final ref = _db.collection('turfs').doc();
      batch.set(ref, turf);
    }
    await batch.commit();
  }

  // ── Bookings ───────────────────────────────────────────

  /// Load all bookings for a specific turf + date (for availability check)
  Future<List<TurfBooking>> getBookingsForTurfDate(String turfId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('bookings')
        .where('turfId', isEqualTo: turfId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isNotEqualTo: 'cancelled')
        .get();

    return snapshot.docs.map((d) => TurfBooking.fromFirestore(d)).toList();
  }

  /// Real-time stream of bookings for turf+date (used in schedule view)
  Stream<List<TurfBooking>> streamBookingsForTurfDate(String turfId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('bookings')
        .where('turfId', isEqualTo: turfId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) => snap.docs.map((d) => TurfBooking.fromFirestore(d)).toList());
  }

  /// Stream of all upcoming bookings (community visibility)
  Stream<List<TurfBooking>> streamAllUpcomingBookings() {
    final now = Timestamp.fromDate(DateTime.now());
    return _db
        .collection('bookings')
        .where('date', isGreaterThanOrEqualTo: now)
        .where('status', isNotEqualTo: 'cancelled')
        .orderBy('date')
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TurfBooking.fromFirestore(d)).toList());
  }

  /// Load current user's bookings
  Future<void> loadMyBookings(String userId) async {
    try {
      final snap = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      _myBookings = snap.docs.map((d) => TurfBooking.fromFirestore(d)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading my bookings: $e');
    }
  }

  /// Stream of current user's bookings (real-time)
  Stream<List<TurfBooking>> streamMyBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TurfBooking.fromFirestore(d)).toList());
  }

  /// Create a new booking (with conflict check)
  Future<String?> createBooking(TurfBooking booking) async {
    try {
      // Double-check for conflicts before writing
      final existing = await getBookingsForTurfDate(booking.turfId, booking.date);
      final conflict = existing.any((b) =>
          b.status != BookingStatus.cancelled &&
          b.startHour < booking.endHour &&
          b.endHour > booking.startHour);

      if (conflict) {
        return 'This slot is already booked. Please choose another time.';
      }

      await _db.collection('bookings').add(booking.toMap());
      return null;
    } catch (e) {
      return 'Booking failed: ${e.toString()}';
    }
  }

  /// Cancel a booking
  Future<String?> cancelBooking(String bookingId) async {
    try {
      await _db.collection('bookings').doc(bookingId).update({'status': 'cancelled'});
      return null;
    } catch (e) {
      return 'Could not cancel booking: ${e.toString()}';
    }
  }

  // ── Helpers ────────────────────────────────────────────

  /// Get list of available slots for a turf on a date
  Future<List<Map<String, dynamic>>> getAvailableSlots(String turfId, DateTime date) async {
    final booked = await getBookingsForTurfDate(turfId, date);
    final bookedHours = <int>{};

    for (final b in booked) {
      if (b.status != BookingStatus.cancelled) {
        for (int h = b.startHour; h < b.endHour; h++) {
          bookedHours.add(h);
        }
      }
    }

    const openHour = 6;  // 6 AM
    const closeHour = 22; // 10 PM

    final slots = <Map<String, dynamic>>[];
    for (int h = openHour; h < closeHour; h++) {
      final isBooked = bookedHours.contains(h);
      slots.add({
        'startHour': h,
        'endHour': h + 1,
        'label': _formatHour(h),
        'isBooked': isBooked,
      });
    }
    return slots;
  }

  String _formatHour(int hour) {
    final suffix = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final endHour = hour + 1;
    final endSuffix = endHour < 12 ? 'AM' : 'PM';
    final displayEnd = endHour == 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
    return '$displayHour:00 $suffix – $displayEnd:00 $endSuffix';
  }
}
