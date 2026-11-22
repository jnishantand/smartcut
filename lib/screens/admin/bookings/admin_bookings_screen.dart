import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildBookingsList(status: 'confirmed', isTodayOnly: true),
            _buildBookingsList(status: 'confirmed', isTodayOnly: false),
            _buildBookingsList(status: 'completed', isTodayOnly: false),
            _buildBookingsList(status: 'cancelled', isTodayOnly: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList({required String status, required bool isTodayOnly}) {
    return StreamBuilder<List<Booking>>(
      stream: FirestoreService().getAdminBookings(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var bookings = snapshot.data ?? [];

        if (isTodayOnly) {
          final now = DateTime.now();
          bookings = bookings.where((b) => 
            b.appointmentDate.year == now.year &&
            b.appointmentDate.month == now.month &&
            b.appointmentDate.day == now.day
          ).toList();
        }

        if (bookings.isEmpty) {
          return Center(child: Text('No bookings found.', style: const TextStyle(color: AppColors.textSecondary)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final b = bookings[index];
            final dateStr = isTodayOnly 
                ? 'Today, ${b.timeSlot}'
                : '${b.appointmentDate.day}/${b.appointmentDate.month}/${b.appointmentDate.year}, ${b.timeSlot}';
                
            return _buildAdminBookingCard(
              b.id,
              b.customerName,
              b.serviceName,
              dateStr,
              b.staffName,
              b.paymentStatus == 'advance_paid' ? 'Advance Paid' : 'Paid in Full',
              b.bookingStatus.toUpperCase()
            );
          },
        );
      }
    );
  }

  Widget _buildAdminBookingCard(String id, String customerName, String service, String time, String staff, String payment, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.secondary,
                      child: Text(customerName[0], style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(service, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(staff, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(payment, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: (){}),
                    IconButton(icon: const Icon(Icons.cancel_outlined, color: AppColors.error), onPressed: (){}),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
