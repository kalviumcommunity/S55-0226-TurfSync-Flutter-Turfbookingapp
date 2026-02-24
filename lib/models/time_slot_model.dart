/// Represents a single time slot for a turf.
/// Used to display available/booked slots on the calendar view.
class TimeSlotModel {
  final String startTime; // "09:00"
  final String endTime; // "10:00"
  final String slotKey; // "09:00-10:00"
  final bool isBooked;
  final String? bookedByUserId;
  final String? bookingId;

  const TimeSlotModel({
    required this.startTime,
    required this.endTime,
    required this.slotKey,
    this.isBooked = false,
    this.bookedByUserId,
    this.bookingId,
  });

  /// Creates a copy with optional overrides.
  TimeSlotModel copyWith({
    String? startTime,
    String? endTime,
    String? slotKey,
    bool? isBooked,
    String? bookedByUserId,
    String? bookingId,
  }) {
    return TimeSlotModel(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotKey: slotKey ?? this.slotKey,
      isBooked: isBooked ?? this.isBooked,
      bookedByUserId: bookedByUserId ?? this.bookedByUserId,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  /// Returns a copy marked as booked.
  TimeSlotModel markAsBooked({
    required String userId,
    required String bookingId,
  }) {
    return copyWith(
      isBooked: true,
      bookedByUserId: userId,
      bookingId: bookingId,
    );
  }

  /// Returns a copy marked as available.
  TimeSlotModel markAsAvailable() {
    return copyWith(isBooked: false);
  }
}
