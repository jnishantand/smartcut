import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/service_card.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../models/salon_service.dart';
import '../../../models/booking.dart';
import '../../../providers/booking_provider.dart';
import '../booking/service_selection_screen.dart';
import '../booking/staff_selection_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSalonStatusCard(context),
              _buildBookButton(context),
              _buildPopularServices(context),
              _buildUpcomingAppointment(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;
        final isLoading = userProvider.isLoading;
        final name = profile?.name ?? 'Customer';

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading ? 'Loading...' : 'Hello, $name',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Smart Salon & Spa',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondary,
                child: Text(
                  isLoading || name.isEmpty ? '?' : name[0].toUpperCase(), 
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalonStatusCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirestoreService().getSalonStatus(),
          builder: (context, snapshot) {
            int currentCustomers = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              currentCustomers = data['currentCustomers'] ?? 0;
            }

            final status = currentCustomers > 5 
                ? SalonStatus.busy 
                : SalonStatus.available;
            
            final waitTime = currentCustomers > 5 ? '${(currentCustomers * 15)} min' : 'No Wait';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Availability',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatusStat(context, 'In Salon', '$currentCustomers', Icons.people_outline),
                    const SizedBox(width: 24),
                    _buildStatusStat(context, 'Est. Wait', waitTime, Icons.timer_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Waiting times are estimates and may vary.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildStatusStat(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ],
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text('Book an Appointment'),
      ),
    );
  }

  Widget _buildPopularServices(BuildContext context) {
    final List<SalonService> defaultServices = [
      SalonService(id: 's1', name: "Men's Classic Haircut", category: 'Haircuts', durationMinutes: 45, price: 250, advanceRequired: 50, isActive: true),
      SalonService(id: 's2', name: 'Kids Haircut', category: 'Haircuts', durationMinutes: 30, price: 150, advanceRequired: 50, isActive: true),
      SalonService(id: 's3', name: 'Beard Trim & Styling', category: 'Beard & Grooming', durationMinutes: 30, price: 150, advanceRequired: 50, isActive: true),
      SalonService(id: 's4', name: 'Skin Fade Haircut', category: 'Haircuts', durationMinutes: 60, price: 350, advanceRequired: 100, isActive: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Popular Services', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()),
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: StreamBuilder<List<SalonService>>(
            stream: FirestoreService().getActiveServices(),
            builder: (context, snapshot) {
              final services = (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : defaultServices;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceCard(
                    title: service.name,
                    duration: '${service.durationMinutes} mins',
                    price: service.price.toStringAsFixed(0),
                    onTap: () {
                      context.read<BookingProvider>().selectService(service);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StaffSelectionScreen()),
                      );
                    },
                  );
                },
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointment(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;
        if (profile == null) return const SizedBox.shrink();

        return StreamBuilder<List<Booking>>(
          stream: FirestoreService().getUserBookings(profile.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            // Find the closest upcoming confirmed appointment
            final upcomingBookings = snapshot.data!
                .where((b) => b.bookingStatus == 'confirmed' && b.appointmentDate.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
                .toList();

            if (upcomingBookings.isEmpty) return const SizedBox.shrink();

            // Sort to get the earliest one
            upcomingBookings.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
            final nextBooking = upcomingBookings.first;
            
            final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Appointment', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text('${nextBooking.appointmentDate.day}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                              Text(monthNames[nextBooking.appointmentDate.month - 1], style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nextBooking.serviceName, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(nextBooking.timeSlot, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
        );
      }
    );
  }
}
