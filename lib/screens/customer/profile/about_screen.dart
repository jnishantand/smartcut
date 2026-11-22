import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SmartCut'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 90,
                    height: 90,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SmartCut Salon',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Smart Salon Booking & Queue Management',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('About Us', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text(
            'SmartCut is a modern salon and grooming app designed to revolutionize how you schedule hair appointments and manage waiting times. We bring transparency, convenience, and luxury grooming right to your fingertips.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Text('Key Features', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildFeatureItem(Icons.schedule, 'Live Queue Counter', 'Real-time estimate of current salon availability.'),
          _buildFeatureItem(Icons.content_cut, 'Expert Stylists', 'Choose your favorite professional for every service.'),
          _buildFeatureItem(Icons.payment, 'Instant Advance Payment', 'Seamless Razorpay integration with UPI and Card options.'),
          _buildFeatureItem(Icons.notifications_active, 'Smart Reminders', 'Automated reminders before your appointment.'),
          const SizedBox(height: 24),
          Text('Contact & Location', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(child: Text('123 Main Street, Downtown Cityville', style: TextStyle(fontSize: 14))),
                  ],
                ),
                Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(child: Text('+1 (800) 555-SMART', style: TextStyle(fontSize: 14))),
                  ],
                ),
                Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(child: Text('support@smartcut.com', style: TextStyle(fontSize: 14))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              '© 2026 SmartCut Inc. All rights reserved.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
