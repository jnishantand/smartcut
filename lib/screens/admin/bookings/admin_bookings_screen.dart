import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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
            _buildBookingsList(isToday: true),
            _buildBookingsList(isUpcoming: true),
            _buildBookingsList(isCompleted: true),
            _buildBookingsList(isCancelled: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList({bool isToday = false, bool isUpcoming = false, bool isCompleted = false, bool isCancelled = false}) {
    // Dummy conditional rendering
    if (isToday) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminBookingCard('Alex Johnson', 'Classic Haircut', 'Today, 3:00 PM', 'Sarah Jenkins', 'Advance Paid', 'Confirmed'),
          _buildAdminBookingCard('Sam Smith', 'Beard Trim', 'Today, 4:30 PM', 'Michael Brown', 'Paid in Full', 'Confirmed'),
        ],
      );
    }
    
    return Center(child: Text('No bookings found for this filter.', style: TextStyle(color: AppColors.textSecondary)));
  }

  Widget _buildAdminBookingCard(String customerName, String service, String time, String staff, String payment, String status) {
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
