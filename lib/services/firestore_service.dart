import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../models/salon_service.dart';
import '../models/staff.dart';

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

  Stream<List<Booking>> getTodayConfirmedBookings() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection('bookings')
        .where('bookingStatus', isEqualTo: 'confirmed')
        .where('appointmentDate', isGreaterThanOrEqualTo: startOfDay)
        .where('appointmentDate', isLessThanOrEqualTo: endOfDay)
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

  // --- Staff / Barbers ---
  Stream<List<Staff>> getActiveStaff() {
    return _db
        .collection('staff')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList());
  }

  Stream<List<Staff>> getAllStaff() {
    return _db
        .collection('staff')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList());
  }

  Future<void> addStaff(Staff staff) async {
    await _db.collection('staff').add(staff.toMap());
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    await _db.collection('staff').doc(id).update(data);
  }

  Future<void> seedSampleStaff() async {
    final batch = _db.batch();

    final b1 = _db.collection('staff').doc('alex_johnson');
    batch.set(b1, {
      'name': 'Alex Johnson',
      'role': 'Master Barber',
      'rating': 4.9,
      'experienceYears': 8,
      'isActive': true,
    });

    final b2 = _db.collection('staff').doc('marcus_vance');
    batch.set(b2, {
      'name': 'Marcus Vance',
      'role': 'Fade & Beard Specialist',
      'rating': 4.8,
      'experienceYears': 5,
      'isActive': true,
    });

    final b3 = _db.collection('staff').doc('david_miller');
    batch.set(b3, {
      'name': 'David Miller',
      'role': 'Senior Hair Stylist',
      'rating': 4.7,
      'experienceYears': 6,
      'isActive': true,
    });

    await batch.commit();
  }
}
