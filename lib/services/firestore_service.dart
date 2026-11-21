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
