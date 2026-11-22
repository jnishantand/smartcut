import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I book an appointment?',
        'a': 'Select your desired service from the home screen or service menu, choose your preferred professional and available time slot, and pay the small advance deposit to confirm your booking.'
      },
      {
        'q': 'Why is an advance deposit required?',
        'a': 'The advance deposit reserves your dedicated time slot with your stylist, preventing double-bookings and ensuring minimal waiting time when you arrive at SmartCut.'
      },
      {
        'q': 'How does the Live Queue Availability work?',
        'a': 'Our live availability status shows the real-time number of active customers in the salon. It provides an estimated wait time so you can decide whether to walk in or schedule an appointment.'
      },
      {
        'q': 'What payment methods are accepted?',
        'a': 'We integrate directly with Razorpay, supporting UPI (GPay, PhonePe, Paytm), Credit/Debit Cards, Netbanking, and Mobile Wallets.'
      },
      {
        'q': 'Can I cancel or reschedule my appointment?',
        'a': 'Yes! You can view and manage all active appointments under the "My Bookings" tab. You can cancel or modify bookings up to 2 hours before your scheduled appointment.'
      },
      {
        'q': 'Where is SmartCut Salon located?',
        'a': 'SmartCut Salon is located at 123 Main Street, Downtown. You can view our exact location and contact details on the "About SmartCut" page.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Icon(Icons.help_outline, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about SmartCut salon bookings and payments.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...faqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ExpansionTile(
                  title: Text(
                    faq['q']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.textSecondary,
                  shape: const Border(), // Remove default expansion borders
                  children: [
                    Text(
                      faq['a']!,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 14),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_outlined, size: 32, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Still need help?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('Contact support@smartcut.com', style: TextStyle(color: AppColors.primary.withOpacity(0.9), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
