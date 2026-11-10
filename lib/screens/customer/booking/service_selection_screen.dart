import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/service_card.dart';
import 'staff_selection_screen.dart'; // We'll create this next

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
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildCategoryHeader(context, 'Haircuts'),
          const SizedBox(height: 16),
          _buildServiceListItem(context, 'Classic Haircut', '45 mins', '35'),
          _buildServiceListItem(context, 'Skin Fade', '60 mins', '45'),
          _buildServiceListItem(context, 'Kids Haircut', '30 mins', '25'),
          
          const SizedBox(height: 32),
          
          _buildCategoryHeader(context, 'Beard & Grooming'),
          const SizedBox(height: 16),
          _buildServiceListItem(context, 'Beard Trim', '30 mins', '20'),
          _buildServiceListItem(context, 'Hot Towel Shave', '45 mins', '35'),
          _buildServiceListItem(context, 'Full Grooming (Hair & Beard)', '1 hr 15 mins', '60'),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildServiceListItem(BuildContext context, String title, String duration, String price) {
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
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(duration, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$$price', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
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
