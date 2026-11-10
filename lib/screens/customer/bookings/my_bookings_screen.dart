import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildBookingCard(
          serviceName: 'Classic Haircut',
          date: 'Tue, 12 Nov 2024',
          time: '09:45 AM',
          staffName: 'Michael Brown',
          bookingId: '#SC-8492',
          paymentStatus: 'Advance Paid',
          status: 'Confirmed',
          isUpcoming: true,
        ),
      ],
    );
  }

  Widget _buildCompletedBookings() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildBookingCard(
          serviceName: 'Beard Trim',
          date: 'Sat, 02 Nov 2024',
          time: '02:00 PM',
          staffName: 'Sarah Jenkins',
          bookingId: '#SC-7301',
          paymentStatus: 'Paid in Full',
          status: 'Completed',
          isUpcoming: false,
        ),
      ],
    );
  }

  Widget _buildCancelledBookings() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildBookingCard(
          serviceName: 'Hair Coloring',
          date: 'Fri, 25 Oct 2024',
          time: '11:00 AM',
          staffName: 'Any Available',
          bookingId: '#SC-6544',
          paymentStatus: 'Refunded',
          status: 'Cancelled',
          isUpcoming: false,
        ),
      ],
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
