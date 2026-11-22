import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/staff.dart';
import '../../../services/firestore_service.dart';
import '../../../providers/booking_provider.dart';
import 'time_selection_screen.dart';

class StaffSelectionScreen extends StatelessWidget {
  const StaffSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Staff> defaultStaff = [
      Staff(id: 'alex', name: 'Alex Johnson', role: 'Master Barber', rating: 4.9, experienceYears: 8, isActive: true),
      Staff(id: 'marcus', name: 'Marcus Vance', role: 'Fade & Beard Specialist', rating: 4.8, experienceYears: 5, isActive: true),
      Staff(id: 'david', name: 'David Miller', role: 'Senior Hair Stylist', rating: 4.7, experienceYears: 6, isActive: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Professional'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Staff>>(
        stream: FirestoreService().getActiveStaff(),
        builder: (context, snapshot) {
          final staffList = (snapshot.hasData && snapshot.data!.isNotEmpty)
              ? snapshot.data!
              : defaultStaff;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _buildAnyStaffOption(context),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('OR CHOOSE SPECIFIC', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              ...staffList.map((staff) => _buildStaffMember(context, staff)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnyStaffOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<BookingProvider>().selectStaff('any', 'Any Available Staff');
        _navigateToNext(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Any Available Staff', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Find the earliest available time', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffMember(BuildContext context, Staff staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.secondary,
          child: Text(
            staff.name[0].toUpperCase(),
            style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(staff.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${staff.role} • ${staff.experienceYears} yrs exp'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(staff.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.read<BookingProvider>().selectStaff(staff.id, staff.name);
          _navigateToNext(context);
        },
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const TimeSelectionScreen())
    );
  }
}
