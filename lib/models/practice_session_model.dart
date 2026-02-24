import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a practice session created by a Coach.
/// Stored in the `sessions` Firestore collection.
class PracticeSessionModel {
  final String id;
  final String title;
  final String description;
  final String coachId;
  final String coachName;
  final String turfId;
  final String turfName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int maxPlayers;
  final List<String> joinedPlayerIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PracticeSessionModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.coachId,
    required this.coachName,
    required this.turfId,
    required this.turfName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxPlayers,
    this.joinedPlayerIds = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Current number of players who have joined.
  int get currentPlayerCount => joinedPlayerIds.length;

  /// Whether the session is full.
  bool get isFull => currentPlayerCount >= maxPlayers;

  /// Whether a specific player has joined.
  bool hasPlayerJoined(String playerId) => joinedPlayerIds.contains(playerId);

  /// Creates a PracticeSessionModel from a Firestore document snapshot.
  factory PracticeSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PracticeSessionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'] ?? '',
      turfId: data['turfId'] ?? '',
      turfName: data['turfName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      maxPlayers: data['maxPlayers'] ?? 10,
      joinedPlayerIds: List<String>.from(data['joinedPlayerIds'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'coachId': coachId,
      'coachName': coachName,
      'turfId': turfId,
      'turfName': turfName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'maxPlayers': maxPlayers,
      'joinedPlayerIds': joinedPlayerIds,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy with updated fields.
  PracticeSessionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coachId,
    String? coachName,
    String? turfId,
    String? turfName,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? maxPlayers,
    List<String>? joinedPlayerIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PracticeSessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      turfId: turfId ?? this.turfId,
      turfName: turfName ?? this.turfName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      joinedPlayerIds: joinedPlayerIds ?? this.joinedPlayerIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
