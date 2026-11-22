import 'package:cloud_firestore/cloud_firestore.dart';

class SalonService {
  final String id;
  final String name;
  final String category;
  final int durationMinutes;
  final double price;
  final double advanceRequired;
  final String? imageUrl;
  final bool isActive;

  SalonService({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.price,
    required this.advanceRequired,
    this.imageUrl,
    required this.isActive,
  });

  factory SalonService.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SalonService(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'General',
      durationMinutes: data['durationMinutes'] ?? 30,
      price: (data['price'] ?? 0).toDouble(),
      advanceRequired: (data['advanceRequired'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'durationMinutes': durationMinutes,
      'price': price,
      'advanceRequired': advanceRequired,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
