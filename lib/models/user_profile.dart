import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String phoneNumber;
  final String name;
  final String email;
  final String role; // 'customer' or 'admin'
  final Map<String, dynamic> notificationSettings;

  UserProfile({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.role,
    required this.notificationSettings,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      name: data['name'] ?? 'Customer',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      notificationSettings: data['notificationSettings'] ?? {
        'bookingUpdates': true,
        'appointmentReminders': true,
        'salonAnnouncements': true,
        'promotions': false,
      },
    );
  }
}
