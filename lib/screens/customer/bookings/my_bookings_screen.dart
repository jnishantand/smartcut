import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../models/booking.dart';
import '../../../widgets/booking_details_dialog.dart';

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
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
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
                return _buildBookingCard(context, b);
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
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
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
                return _buildBookingCard(context, b);
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
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
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
                return _buildBookingCard(context, b);
              },
            );
          }
        );
      }
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final isUpcoming = booking.bookingStatus == 'confirmed';
    final dateStr = '${booking.appointmentDate.day}/${booking.appointmentDate.month}/${booking.appointmentDate.year}';
    final isCancelled = booking.bookingStatus == 'cancelled';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => showBookingDetailsDialog(context, booking),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${booking.id}', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming ? AppColors.secondary : (isCancelled ? AppColors.errorLight : AppColors.successLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.bookingStatus.toUpperCase(), 
                      style: TextStyle(
                        color: isUpcoming ? AppColors.primary : (isCancelled ? AppColors.error : AppColors.success),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(booking.serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(dateStr, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(booking.timeSlot, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(booking.staffName, style: const TextStyle(color: AppColors.textSecondary)),
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
                      const Text('Advance Paid', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('₹${booking.advancePaid.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showBookingDetailsDialog(context, booking),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Details'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
