/// Defines user roles within TurfSync.
/// Each role has specific permissions and dashboard views.
enum UserRole {
  admin,
  coach,
  player;

  /// Convert enum to Firestore-safe string.
  String toFirestore() => name;

  /// Parse a string from Firestore into a UserRole.
  static UserRole fromFirestore(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.player,
    );
  }

  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.coach:
        return 'Coach';
      case UserRole.player:
        return 'Player';
    }
  }

  /// Description shown during role selection.
  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Manage turfs, approve bookings, and oversee operations';
      case UserRole.coach:
        return 'Create practice sessions and manage team schedules';
      case UserRole.player:
        return 'Book turfs, join sessions, and view schedules';
    }
  }
}
