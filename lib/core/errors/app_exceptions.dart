/// Custom exception types for structured error handling across TurfSync.

/// Base class for all app-specific exceptions.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when authentication fails.
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Thrown when a Firestore operation fails.
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}

/// Thrown when a booking conflict (double booking) is detected.
class DoubleBookingException extends AppException {
  const DoubleBookingException([
    super.message = 'This time slot is already booked!',
  ]) : super(code: 'DOUBLE_BOOKING');
}

/// Thrown when a user lacks permission for an action.
class PermissionException extends AppException {
  const PermissionException([
    super.message = 'You do not have permission to perform this action',
  ]) : super(code: 'PERMISSION_DENIED');
}

/// Thrown when a requested resource is not found.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found',
  ]) : super(code: 'NOT_FOUND');
}

/// Thrown when network connectivity is unavailable.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]) : super(code: 'NETWORK_ERROR');
}

/// Maps Firebase Auth error codes to user-friendly messages.
String mapFirebaseAuthError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email';
    case 'wrong-password':
      return 'Incorrect password';
    case 'email-already-in-use':
      return 'An account already exists with this email';
    case 'weak-password':
      return 'Password is too weak';
    case 'invalid-email':
      return 'Please enter a valid email address';
    case 'user-disabled':
      return 'This account has been disabled';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled';
    default:
      return 'Authentication failed. Please try again.';
  }
}
