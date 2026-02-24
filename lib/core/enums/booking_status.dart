/// Defines possible states for a booking in TurfSync.
enum BookingStatus {
  pending,
  approved,
  rejected;

  /// Convert enum to Firestore-safe string.
  String toFirestore() => name;

  /// Parse a string from Firestore into a BookingStatus.
  static BookingStatus fromFirestore(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BookingStatus.pending,
    );
  }

  /// Alias for [fromFirestore].
  static BookingStatus fromString(String value) => fromFirestore(value);

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }
}
