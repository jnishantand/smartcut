import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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
              Tab(text: 'Waiting (4)'),
              Tab(text: 'Serving (3)'),
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
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildQueueItem(
          name: 'Jake Peralta',
          service: 'Classic Haircut',
          waitTime: 'Waiting for 15 mins',
          isWalkIn: true,
          actionLabel: 'Start Serving',
          actionColor: AppColors.primary,
        ),
        _buildQueueItem(
          name: 'Amy Santiago',
          service: 'Hair Coloring',
          waitTime: 'Waiting for 5 mins',
          isWalkIn: false,
          appointmentTime: '3:00 PM',
          actionLabel: 'Start Serving',
          actionColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildServingList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildQueueItem(
          name: 'Charles Boyle',
          service: 'Beard Trim',
          waitTime: 'Serving for 20 mins',
          isWalkIn: true,
          actionLabel: 'Complete',
          actionColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildCompletedList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildQueueItem(
          name: 'Rosa Diaz',
          service: 'Skin Fade',
          waitTime: 'Completed at 2:45 PM',
          isWalkIn: false,
          actionLabel: 'View Receipt',
          actionColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildQueueItem({
    required String name,
    required String service,
    required String waitTime,
    required bool isWalkIn,
    String? appointmentTime,
    required String actionLabel,
    required Color actionColor,
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
                onPressed: () {},
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
