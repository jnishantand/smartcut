import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'payment_screen.dart'; // We'll create this next

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildSectionTitle(context, 'Service Details'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildDetailRow('Service', 'Classic Haircut'),
                      const Divider(height: 24),
                      _buildDetailRow('Duration', '45 mins'),
                      const Divider(height: 24),
                      _buildDetailRow('Professional', 'Any Available'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Date & Time'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildDetailRow('Date', 'Tue, 12 Nov 2024'),
                      const Divider(height: 24),
                      _buildDetailRow('Time', '09:45 AM'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Location'),
                _buildCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Salon & Spa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('123 Main Street, Cityville', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Payment Summary'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildDetailRow('Service Total', '\$35.00'),
                      const Divider(height: 24),
                      _buildDetailRow('Advance Required', '\$10.00', isBold: true, color: AppColors.primary),
                      const SizedBox(height: 8),
                      const Text(
                        'An advance payment is required to confirm your booking. The remaining \$25.00 will be paid at the salon.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500, 
            fontSize: 16,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const PaymentScreen())
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text('Proceed to Pay \$10.00'),
      ),
    );
  }
}
