import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String id;
  final String name;
  final String role;
  final double rating;
  final int experienceYears;
  final String? imageUrl;
  final bool isActive;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.experienceYears,
    this.imageUrl,
    required this.isActive,
  });

  factory Staff.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Staff(
      id: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? 'Barber',
      rating: (data['rating'] ?? 4.8).toDouble(),
      experienceYears: data['experienceYears'] ?? 3,
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'rating': rating,
      'experienceYears': experienceYears,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
