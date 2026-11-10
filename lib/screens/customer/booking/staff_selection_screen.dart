import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'time_selection_screen.dart'; // We'll create this next

class StaffSelectionScreen extends StatelessWidget {
  const StaffSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Professional'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
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
          _buildStaffMember(context, 'Michael Brown', 'Senior Barber', '4.9'),
          _buildStaffMember(context, 'Sarah Jenkins', 'Stylist', '4.8'),
          _buildStaffMember(context, 'David Miller', 'Barber', '4.7'),
        ],
      ),
    );
  }

  Widget _buildAnyStaffOption(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToNext(context),
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

  Widget _buildStaffMember(BuildContext context, String name, String role, String rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.secondary,
          child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(role),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 16),
                const SizedBox(width: 4),
                Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToNext(context),
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
