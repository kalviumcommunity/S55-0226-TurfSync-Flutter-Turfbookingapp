import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { confirmed, pending, cancelled }

class TurfBooking {
  final String id;
  final String turfId;
  final String turfName;
  final String userId;
  final String userName;
  final String userEmail;
  final String teamName;
  final String sport;
  final DateTime date;
  final String timeSlot;   // e.g. "06:00 AM - 07:00 AM"
  final int startHour;     // 6
  final int endHour;       // 7
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;

  TurfBooking({
    required this.id,
    required this.turfId,
    required this.turfName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.teamName,
    required this.sport,
    required this.date,
    required this.timeSlot,
    required this.startHour,
    required this.endHour,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory TurfBooking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TurfBooking(
      id: doc.id,
      turfId: data['turfId'] ?? '',
      turfName: data['turfName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      teamName: data['teamName'] ?? '',
      sport: data['sport'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      startHour: data['startHour'] ?? 0,
      endHour: data['endHour'] ?? 1,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'confirmed'),
        orElse: () => BookingStatus.confirmed,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'turfId': turfId,
      'turfName': turfName,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'teamName': teamName,
      'sport': sport,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'startHour': startHour,
      'endHour': endHour,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TurfBooking copyWith({BookingStatus? status}) {
    return TurfBooking(
      id: id,
      turfId: turfId,
      turfName: turfName,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      teamName: teamName,
      sport: sport,
      date: date,
      timeSlot: timeSlot,
      startHour: startHour,
      endHour: endHour,
      status: status ?? this.status,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

class Turf {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final List<String> sports;
  final double pricePerHour;
  final String description;
  final double rating;
  final int reviewCount;

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.sports,
    required this.pricePerHour,
    required this.description,
    required this.rating,
    required this.reviewCount,
  });

  factory Turf.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Turf(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      sports: List<String>.from(data['sports'] ?? []),
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 4.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'sports': sports,
      'pricePerHour': pricePerHour,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}

// Predefined turf data (seeds to Firestore)
List<Map<String, dynamic>> seedTurfs = [
  {
    'name': 'GreenField Sports Arena',
    'location': 'Koregaon Park, Pune',
    'imageUrl': 'https://images.unsplash.com/photo-1551958219-acbc595d9e52?w=400',
    'sports': ['Football', 'Cricket', 'Hockey'],
    'pricePerHour': 800.0,
    'description': 'Premium synthetic turf with floodlights for night games. Changing rooms and parking available.',
    'rating': 4.7,
    'reviewCount': 124,
  },
  {
    'name': 'Champions Turf Club',
    'location': 'Viman Nagar, Pune',
    'imageUrl': 'https://images.unsplash.com/photo-1509077564905-e3b6c8ab4f56?w=400',
    'sports': ['Football', 'Futsal', 'Basketball'],
    'pricePerHour': 600.0,
    'description': 'Indoor and outdoor courts. Great for community leagues and tournaments.',
    'rating': 4.5,
    'reviewCount': 89,
  },
  {
    'name': 'Sportz Hub',
    'location': 'Hinjewadi, Pune',
    'imageUrl': 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400',
    'sports': ['Cricket', 'Volleyball', 'Football'],
    'pricePerHour': 700.0,
    'description': 'Multi-sport facility with professional-grade equipment and coaching available.',
    'rating': 4.3,
    'reviewCount': 56,
  },
];
