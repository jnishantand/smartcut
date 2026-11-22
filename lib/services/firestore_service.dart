import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../models/salon_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Services ---
  Stream<List<SalonService>> getActiveServices() {
    return _db
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SalonService.fromFirestore(doc))
            .toList());
  }

  Stream<List<SalonService>> getAllServices() {
    return _db
        .collection('services')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SalonService.fromFirestore(doc))
            .toList());
  }

  Future<void> addService(SalonService service) async {
    await _db.collection('services').add(service.toMap());
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _db.collection('services').doc(id).update(data);
  }

  Future<void> seedSampleServices() async {
    final batch = _db.batch();
    
    final s1 = _db.collection('services').doc('classic_haircut');
    batch.set(s1, {
      'name': 'Classic Haircut',
      'category': 'Haircuts',
      'durationMinutes': 45,
      'price': 250.0,
      'advanceRequired': 50.0,
      'isActive': true,
    });

    final s2 = _db.collection('services').doc('skin_fade');
    batch.set(s2, {
      'name': 'Skin Fade Haircut',
      'category': 'Haircuts',
      'durationMinutes': 60,
      'price': 350.0,
      'advanceRequired': 100.0,
      'isActive': true,
    });

    final s3 = _db.collection('services').doc('beard_trim');
    batch.set(s3, {
      'name': 'Beard Trim & Styling',
      'category': 'Beard & Grooming',
      'durationMinutes': 30,
      'price': 150.0,
      'advanceRequired': 50.0,
      'isActive': true,
    });

    final s4 = _db.collection('services').doc('full_grooming');
    batch.set(s4, {
      'name': 'Full Royal Grooming',
      'category': 'Beard & Grooming',
      'durationMinutes': 75,
      'price': 600.0,
      'advanceRequired': 150.0,
      'isActive': true,
    });

    await batch.commit();
  }

  // --- Bookings ---
  Future<void> createBooking(Booking booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('customerId', isEqualTo: userId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Stream<List<Booking>> getAdminBookings(String status) {
    return _db
        .collection('bookings')
        .where('bookingStatus', isEqualTo: status)
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'bookingStatus': status,
    });
  }

  // --- Salon Status (Admin Queue Management) ---
  Stream<DocumentSnapshot> getSalonStatus() {
    return _db.collection('settings').doc('salon_status').snapshots();
  }

  Future<void> updateSalonCustomerCount(int count) async {
    await _db.collection('settings').doc('salon_status').set(
        {'currentCustomers': count, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }
}
