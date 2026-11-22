import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../models/booking.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingBookings(),
            _buildCompletedBookings(),
            _buildCancelledBookings(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBookings() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;
        if (profile == null) return const Center(child: Text("Please log in"));

        return StreamBuilder<List<Booking>>(
          stream: FirestoreService().getUserBookings(profile.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data?.where((b) => b.bookingStatus == 'confirmed').toList() ?? [];

            if (bookings.isEmpty) {
              return const Center(child: Text("No upcoming bookings"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                return _buildBookingCard(
                  serviceName: b.serviceName,
                  date: '${b.appointmentDate.day}/${b.appointmentDate.month}/${b.appointmentDate.year}',
                  time: b.timeSlot,
                  staffName: b.staffName,
                  bookingId: '#${b.id}',
                  paymentStatus: 'Advance Paid',
                  status: 'Confirmed',
                  isUpcoming: true,
                );
              },
            );
          }
        );
      }
    );
  }

  Widget _buildCompletedBookings() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;
        if (profile == null) return const Center(child: Text("Please log in"));

        return StreamBuilder<List<Booking>>(
          stream: FirestoreService().getUserBookings(profile.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data?.where((b) => b.bookingStatus == 'completed').toList() ?? [];

            if (bookings.isEmpty) {
              return const Center(child: Text("No completed bookings"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                return _buildBookingCard(
                  serviceName: b.serviceName,
                  date: '${b.appointmentDate.day}/${b.appointmentDate.month}/${b.appointmentDate.year}',
                  time: b.timeSlot,
                  staffName: b.staffName,
                  bookingId: '#${b.id}',
                  paymentStatus: 'Paid in Full',
                  status: 'Completed',
                  isUpcoming: false,
                );
              },
            );
          }
        );
      }
    );
  }

  Widget _buildCancelledBookings() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;
        if (profile == null) return const Center(child: Text("Please log in"));

        return StreamBuilder<List<Booking>>(
          stream: FirestoreService().getUserBookings(profile.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data?.where((b) => b.bookingStatus == 'cancelled').toList() ?? [];

            if (bookings.isEmpty) {
              return const Center(child: Text("No cancelled bookings"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final b = bookings[index];
                return _buildBookingCard(
                  serviceName: b.serviceName,
                  date: '${b.appointmentDate.day}/${b.appointmentDate.month}/${b.appointmentDate.year}',
                  time: b.timeSlot,
                  staffName: b.staffName,
                  bookingId: '#${b.id}',
                  paymentStatus: 'Refunded',
                  status: 'Cancelled',
                  isUpcoming: false,
                );
              },
            );
          }
        );
      }
    );
  }

  Widget _buildBookingCard({
    required String serviceName,
    required String date,
    required String time,
    required String staffName,
    required String bookingId,
    required String paymentStatus,
    required String status,
    required bool isUpcoming,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(bookingId, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? AppColors.secondary : (status == 'Cancelled' ? AppColors.errorLight : AppColors.successLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status, 
                    style: TextStyle(
                      color: isUpcoming ? AppColors.primary : (status == 'Cancelled' ? AppColors.error : AppColors.success),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(staffName, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text(paymentStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                if (isUpcoming)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ],
                  )
                else
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('View Details'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
