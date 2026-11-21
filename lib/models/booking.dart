import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final String staffId;
  final String staffName;
  final DateTime appointmentDate;
  final String timeSlot;
  final double totalAmount;
  final double advancePaid;
  final String paymentStatus; // 'pending', 'advance_paid', 'paid'
  final String bookingStatus; // 'confirmed', 'completed', 'cancelled'
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.staffId,
    required this.staffName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.totalAmount,
    required this.advancePaid,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      advancePaid: (data['advancePaid'] ?? 0).toDouble(),
      paymentStatus: data['paymentStatus'] ?? 'pending',
      bookingStatus: data['bookingStatus'] ?? 'confirmed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'staffId': staffId,
      'staffName': staffName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'totalAmount': totalAmount,
      'advancePaid': advancePaid,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
