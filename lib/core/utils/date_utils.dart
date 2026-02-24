import 'package:intl/intl.dart';
import '../../models/time_slot_model.dart';

/// Date/time utility helpers for TurfSync.
class AppDateUtils {
  AppDateUtils._();

  /// Formats a DateTime as "Mon, Jan 15, 2026".
  static String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  /// Formats a DateTime as "Jan 15".
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Formats time as "09:00 AM".
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Formats time range as "09:00 AM - 10:00 AM".
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Formats a DateTime as "2026-01-15" for Firestore document IDs.
  static String toDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parses a date key back to DateTime.
  static DateTime fromDateKey(String key) {
    return DateFormat('yyyy-MM-dd').parse(key);
  }

  /// Generates time slots for a turf given start hour, end hour, and duration.
  /// Returns a list of [TimeSlotModel] with string-based start/end times.
  static List<TimeSlotModel> generateTimeSlots({
    required int startHour,
    required int endHour,
    required int durationMinutes,
  }) {
    final slots = <TimeSlotModel>[];
    var currentMinutes = startHour * 60;
    final endMinutes = endHour * 60;

    while (currentMinutes + durationMinutes <= endMinutes) {
      final startH = currentMinutes ~/ 60;
      final startM = currentMinutes % 60;
      final endTotal = currentMinutes + durationMinutes;
      final endH = endTotal ~/ 60;
      final endM = endTotal % 60;

      final startStr =
          '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}';
      final endStr =
          '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';

      slots.add(TimeSlotModel(
        startTime: startStr,
        endTime: endStr,
        slotKey: '$startStr-$endStr',
      ));

      currentMinutes = endTotal;
    }

    return slots;
  }

  /// Checks if two dates are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns true if the given date is today.
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Returns true if the given date is in the past.
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Creates a time slot key for Firestore (e.g., "09:00-10:00").
  static String toSlotKey(DateTime start, DateTime end) {
    final startStr = DateFormat('HH:mm').format(start);
    final endStr = DateFormat('HH:mm').format(end);
    return '$startStr-$endStr';
  }
}
