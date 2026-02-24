import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/booking_status.dart';

/// Represents a turf booking in TurfSync.
/// Stored in the `bookings` Firestore collection.
/// Uses a composite key (turfId + date + slotKey) to prevent double bookings.
class BookingModel {
  final String id;
  final String turfId;
  final String turfName;
  final String userId;
  final String userName;
  final DateTime date;
  final String slotKey; // e.g., "09:00-10:00"
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "10:00"
  final BookingStatus status;
  final String? notes;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingModel({
    required this.id,
    required this.turfId,
    required this.turfName,
    required this.userId,
    required this.userName,
    required this.date,
    required this.slotKey,
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.pending,
    this.notes,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a BookingModel from a Firestore document snapshot.
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      turfId: data['turfId'] ?? '',
      turfName: data['turfName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      slotKey: data['slotKey'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: BookingStatus.fromFirestore(data['status'] ?? 'pending'),
      notes: data['notes'],
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'turfId': turfId,
      'turfName': turfName,
      'userId': userId,
      'userName': userName,
      'date': Timestamp.fromDate(date),
      'slotKey': slotKey,
      'startTime': startTime,
      'endTime': endTime,
      'status': status.toFirestore(),
      'notes': notes,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Unique composite key used to prevent double bookings.
  /// Format: turfId_YYYY-MM-DD_HH:mm-HH:mm
  String get compositeKey => '${turfId}_${_dateKey}_$slotKey';

  String get _dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Creates a copy with updated fields.
  BookingModel copyWith({
    String? id,
    String? turfId,
    String? turfName,
    String? userId,
    String? userName,
    DateTime? date,
    String? slotKey,
    String? startTime,
    String? endTime,
    BookingStatus? status,
    String? notes,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      turfId: turfId ?? this.turfId,
      turfName: turfName ?? this.turfName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      slotKey: slotKey ?? this.slotKey,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
