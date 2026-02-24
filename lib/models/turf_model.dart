import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a turf (sports ground) in TurfSync.
/// Stored in the `turfs` Firestore collection.
class TurfModel {
  final String id;
  final String name;
  final String location;
  final String description;
  final int startHour; // Opening hour (0-23)
  final int endHour; // Closing hour (0-23)
  final int slotDuration; // Duration per slot in minutes
  final double pricePerSlot; // Price per booking slot
  final String? imageUrl;
  final bool isActive;
  final String createdBy; // Admin UID who created this turf
  final DateTime createdAt;
  final DateTime updatedAt;

  const TurfModel({
    required this.id,
    required this.name,
    required this.location,
    this.description = '',
    required this.startHour,
    required this.endHour,
    required this.slotDuration,
    this.pricePerSlot = 0.0,
    this.imageUrl,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a TurfModel from a Firestore document snapshot.
  factory TurfModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TurfModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      startHour: data['startHour'] ?? 6,
      endHour: data['endHour'] ?? 22,
      slotDuration: data['slotDuration'] ?? 60,
      pricePerSlot: (data['pricePerSlot'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'startHour': startHour,
      'endHour': endHour,
      'slotDuration': slotDuration,
      'pricePerSlot': pricePerSlot,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy with updated fields.
  TurfModel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    int? startHour,
    int? endHour,
    int? slotDuration,
    double? pricePerSlot,
    String? imageUrl,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TurfModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      slotDuration: slotDuration ?? this.slotDuration,
      pricePerSlot: pricePerSlot ?? this.pricePerSlot,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
