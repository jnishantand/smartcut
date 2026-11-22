import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openMap() async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=247,+near+HDFC+Bank,+Scheme+No+171,+Indore,+Madhya+Pradesh+452010');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch maps: $e');
    }
  }

  Future<void> _openPhone() async {
    final Uri url = Uri.parse('tel:09752315472');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Could not launch phone: $e');
    }
  }

  Future<void> _openEmail() async {
    final Uri url = Uri.parse('mailto:support@smartcut.com');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Could not launch email: $e');
    }
  }

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
            child: Column(
              children: [
                InkWell(
                  onTap: _openMap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '247, near HDFC Bank, Scheme No 171, Indore, Madhya Pradesh 452010',
                            style: TextStyle(fontSize: 14, color: AppColors.primary, decoration: TextDecoration.underline),
                          ),
                        ),
                        Icon(Icons.open_in_new, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                InkWell(
                  onTap: _openPhone,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '09752315472',
                            style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.call, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                InkWell(
                  onTap: _openEmail,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'support@smartcut.com',
                            style: TextStyle(fontSize: 14, color: AppColors.primary),
                          ),
                        ),
                        Icon(Icons.mail_outline, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
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
