import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/salon_service.dart';
import '../../../services/firestore_service.dart';
import '../../../providers/booking_provider.dart';
import 'staff_selection_screen.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<SalonService>>(
        stream: FirestoreService().getActiveServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final List<SalonService> defaultServices = [
            SalonService(id: 's1', name: "Men's Classic Haircut", category: 'Haircuts', durationMinutes: 45, price: 250, advanceRequired: 50, isActive: true),
            SalonService(id: 's2', name: 'Skin Fade Haircut', category: 'Haircuts', durationMinutes: 60, price: 350, advanceRequired: 100, isActive: true),
            SalonService(id: 's3', name: 'Kids Haircut', category: 'Haircuts', durationMinutes: 30, price: 150, advanceRequired: 50, isActive: true),
            SalonService(id: 's4', name: 'Beard Trim & Styling', category: 'Beard & Grooming', durationMinutes: 30, price: 150, advanceRequired: 50, isActive: true),
            SalonService(id: 's5', name: 'Hot Towel Shave', category: 'Beard & Grooming', durationMinutes: 45, price: 250, advanceRequired: 50, isActive: true),
            SalonService(id: 's6', name: 'Full Royal Grooming', category: 'Beard & Grooming', durationMinutes: 75, price: 600, advanceRequired: 150, isActive: true),
          ];

          final services = (snapshot.hasData && snapshot.data!.isNotEmpty)
              ? snapshot.data!
              : defaultServices;
          // Group by category (simple mapping for UI)
          final Map<String, List<SalonService>> categorizedServices = {};
          for (var s in services) {
            if (!categorizedServices.containsKey(s.category)) {
              categorizedServices[s.category] = [];
            }
            categorizedServices[s.category]!.add(s);
          }

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: categorizedServices.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryHeader(context, entry.key),
                  const SizedBox(height: 16),
                  ...entry.value.map((service) => _buildServiceListItem(context, service)),
                  const SizedBox(height: 32),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildServiceListItem(BuildContext context, SalonService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.content_cut, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${service.durationMinutes} mins', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${service.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Update Provider state
                    context.read<BookingProvider>().selectService(service);
                    // Navigate to next step
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const StaffSelectionScreen())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Select'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
