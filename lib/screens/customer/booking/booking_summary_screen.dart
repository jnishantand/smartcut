import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/booking_provider.dart';
import 'payment_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final service = bookingProvider.selectedService;
    final staff = bookingProvider.selectedStaffName;
    final date = bookingProvider.selectedDate;
    final time = bookingProvider.selectedTime;

    if (service == null) {
      return const Scaffold(body: Center(child: Text('Error: No service selected')));
    }

    final dateString = date != null ? "${date.day}/${date.month}/${date.year}" : "";

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
                      _buildDetailRow('Service', service.name),
                      const Divider(height: 24),
                      _buildDetailRow('Duration', '${service.durationMinutes} mins'),
                      const Divider(height: 24),
                      _buildDetailRow('Professional', staff ?? 'Any Available'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Date & Time'),
                _buildCard(
                  child: Column(
                    children: [
                      _buildDetailRow('Date', dateString),
                      const Divider(height: 24),
                      _buildDetailRow('Time', time ?? ''),
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
                      _buildDetailRow('Service Total', '₹${service.price.toStringAsFixed(2)}'),
                      const Divider(height: 24),
                      _buildDetailRow('Advance Required', '₹${service.advanceRequired.toStringAsFixed(2)}', isBold: true, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        'An advance payment is required to confirm your booking. The remaining ₹${(service.price - service.advanceRequired).toStringAsFixed(2)} will be paid at the salon.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(context, service.advanceRequired),
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

  Widget _buildBottomBar(BuildContext context, double advanceRequired) {
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
        child: Text('Proceed to Pay ₹${advanceRequired.toStringAsFixed(2)}'),
      ),
    );
  }
}
