import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentCustomers = 5;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildLiveStatus(context),
              _buildQuickActions(context),
              _buildTodaySummary(context),
              _buildUpcomingAppointments(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Smart Salon & Spa',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.storefront, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatus(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Salon Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Busy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLiveCounter('In Salon', _currentCustomers.toString()),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildLiveCounter('Waiting', '2'),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildLiveCounter('Serving', '3'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() { if(_currentCustomers > 0) _currentCustomers--; }),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Update Count',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() { _currentCustomers++; }),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCounter(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionBtn(context, Icons.person_add_alt_1, 'Walk-in', AppColors.primary),
              _buildActionBtn(context, Icons.access_time, 'Wait Time', AppColors.warning),
              _buildActionBtn(context, Icons.campaign, 'Offer', AppColors.success),
              _buildActionBtn(context, Icons.qr_code_scanner, 'Scan', AppColors.textPrimary),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildActionBtn(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(context, 'Appointments', '12', Icons.calendar_today),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(context, 'Revenue', '\$450', Icons.attach_money),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Next Appointments', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: (){}, child: const Text('View All'))
            ],
          ),
          const SizedBox(height: 8),
          _buildAppointmentTile(context, 'Alex Johnson', 'Classic Haircut', '3:00 PM', 'Available'),
          _buildAppointmentTile(context, 'Sarah Smith', 'Hair Coloring', '3:45 PM', 'Checked-in'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(BuildContext context, String name, String service, String time, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time.split(' ')[0], 
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(service, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            StatusBadge(status: status == 'Available' ? SalonStatus.available : SalonStatus.busy),
          ],
        ),
      ),
    );
  }
}
