import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/status_badge.dart';
import '../../../services/firestore_service.dart';
import '../../../models/booking.dart';
import '../staff/admin_staff_screen.dart';
import '../services/admin_services_screen.dart';
import '../admin_notification_management_screen.dart';
import '../settings/admin_settings_screen.dart';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirestoreService().getSalonStatus(),
          builder: (context, statusSnapshot) {
            int manualOffset = 0;
            if (statusSnapshot.hasData && statusSnapshot.data!.exists) {
              final data = statusSnapshot.data!.data() as Map<String, dynamic>;
              manualOffset = data['currentCustomers'] ?? 0;
            }

            return StreamBuilder<List<Booking>>(
              stream: FirestoreService().getTodayConfirmedBookings(),
              builder: (context, bookingsSnapshot) {
                final todayBookings = bookingsSnapshot.data ?? [];
                final now = DateTime.now();

                final activeBookings = todayBookings.where((b) {
                  final diffMinutes = now.difference(b.appointmentDate).inMinutes;
                  return diffMinutes <= 60 && b.appointmentDate.day == now.day;
                }).toList();

                final int currentCustomers = activeBookings.length + manualOffset;
                final isBusy = currentCustomers >= 4;

                return Column(
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
                            color: isBusy ? AppColors.error : AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(isBusy ? 'Busy' : 'Available', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLiveCounter(context, 'In Salon', '$currentCustomers'),
                        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                        _buildLiveCounter(context, 'Waiting', currentCustomers > 4 ? '${currentCustomers - 4}' : '0'),
                        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                        _buildLiveCounter(context, 'Serving', currentCustomers > 4 ? '4' : '$currentCustomers'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (manualOffset > 0) {
                              FirestoreService().updateSalonCustomerCount(manualOffset - 1);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Walk-In Adj: $manualOffset',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            FirestoreService().updateSalonCustomerCount(manualOffset + 1);
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLiveCounter(BuildContext context, String label, String value) {
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
          Text('Quick Management', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionBtn(
                context, 
                Icons.content_cut, 
                'Services', 
                AppColors.primary,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminServicesScreen()));
                },
              ),
              _buildActionBtn(
                context, 
                Icons.people, 
                'Barbers', 
                AppColors.warning,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStaffScreen()));
                },
              ),
              _buildActionBtn(
                context, 
                Icons.campaign, 
                'Broadcast', 
                AppColors.success,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationManagementScreen()));
                },
              ),
              _buildActionBtn(
                context, 
                Icons.settings, 
                'Settings', 
                AppColors.textPrimary,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen()));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildActionBtn(BuildContext context, IconData icon, String label, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: StreamBuilder<List<Booking>>(
        stream: FirestoreService().getTodayConfirmedBookings(),
        builder: (context, snapshot) {
          final todayBookings = snapshot.data ?? [];
          final appointmentCount = todayBookings.length;
          
          double totalRevenue = 0;
          for (var b in todayBookings) {
            if (b.bookingStatus == 'confirmed' || b.bookingStatus == 'completed') {
              totalRevenue += b.advancePaid;
            }
          }

          return Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context, 
                  'Today Appointments', 
                  '$appointmentCount', 
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context, 
                  'Today Revenue', 
                  '₹${totalRevenue.toStringAsFixed(0)}', 
                  Icons.currency_rupee,
                ),
              ),
            ],
          );
        },
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
          StreamBuilder<List<Booking>>(
            stream: FirestoreService().getAdminBookings('confirmed'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              var bookings = snapshot.data ?? [];
              
              if (bookings.isEmpty) {
                return const Text('No upcoming appointments.', style: TextStyle(color: AppColors.textSecondary));
              }

              // Show only the next 3 appointments for the dashboard
              if (bookings.length > 3) {
                bookings = bookings.sublist(0, 3);
              }

              return Column(
                children: bookings.map((b) => _buildAppointmentTile(
                  context, 
                  b.customerName, 
                  b.serviceName, 
                  b.timeSlot, 
                  'Confirmed'
                )).toList(),
              );
            }
          ),
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
