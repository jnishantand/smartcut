import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../models/booking.dart';

class AdminQueueScreen extends StatelessWidget {
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Queue Management'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Waiting'),
              Tab(text: 'Serving'),
              Tab(text: 'Done'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                // Add walk in logic
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            _buildWaitingList(),
            _buildServingList(),
            _buildCompletedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingList() {
    return StreamBuilder<List<Booking>>(
      stream: FirestoreService().getAdminBookings('confirmed'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final bookings = snapshot.data ?? [];
        
        if (bookings.isEmpty) {
          return const Center(child: Text("No waiting customers"));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final b = bookings[index];
            return _buildQueueItem(
              bookingId: b.id,
              name: b.customerName,
              service: b.serviceName,
              waitTime: 'Scheduled for ${b.timeSlot}',
              isWalkIn: false,
              appointmentTime: b.timeSlot,
              actionLabel: 'Start Serving',
              actionColor: AppColors.primary,
              onActionPressed: () => FirestoreService().updateBookingStatus(b.id, 'serving'),
            );
          },
        );
      },
    );
  }

  Widget _buildServingList() {
    return StreamBuilder<List<Booking>>(
      stream: FirestoreService().getAdminBookings('serving'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final bookings = snapshot.data ?? [];
        
        if (bookings.isEmpty) {
          return const Center(child: Text("No one is currently being served"));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final b = bookings[index];
            return _buildQueueItem(
              bookingId: b.id,
              name: b.customerName,
              service: b.serviceName,
              waitTime: 'Serving now',
              isWalkIn: false,
              actionLabel: 'Complete',
              actionColor: AppColors.success,
              onActionPressed: () => FirestoreService().updateBookingStatus(b.id, 'completed'),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedList() {
    return StreamBuilder<List<Booking>>(
      stream: FirestoreService().getAdminBookings('completed'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final bookings = snapshot.data ?? [];
        
        if (bookings.isEmpty) {
          return const Center(child: Text("No completed bookings yet"));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final b = bookings[index];
            return _buildQueueItem(
              bookingId: b.id,
              name: b.customerName,
              service: b.serviceName,
              waitTime: 'Completed',
              isWalkIn: false,
              actionLabel: 'View Receipt',
              actionColor: AppColors.textSecondary,
              onActionPressed: () {
                // Show receipt logic
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQueueItem({
    required String bookingId,
    required String name,
    required String service,
    required String waitTime,
    required bool isWalkIn,
    String? appointmentTime,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onActionPressed,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Text(name[0], style: const TextStyle(color: AppColors.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          if (isWalkIn)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Walk-in', style: TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.bold)),
                            )
                          else if (appointmentTime != null)
                             Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(appointmentTime, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(service, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(waitTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: actionColor,
                  side: BorderSide(color: actionColor),
                ),
                child: Text(actionLabel),
              ),
            )
          ],
        ),
      ),
    );
  }
}
