import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

void showBookingDetailsDialog(BuildContext context, Booking booking) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(booking.appointmentDate);
      final remainingPrice = booking.totalAmount - booking.advancePaid;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointment Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Ticket Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: #${booking.id}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: booking.bookingStatus == 'confirmed'
                            ? AppColors.success
                            : (booking.bookingStatus == 'completed' ? Colors.white24 : AppColors.error),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.bookingStatus.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Itemized Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildRow(Icons.calendar_month_outlined, 'Date & Time', '$dateStr at ${booking.timeSlot}'),
                    const Divider(height: 20),
                    _buildRow(Icons.person_outline, 'Stylist', booking.staffName),
                    const Divider(height: 20),
                    _buildRow(Icons.location_on_outlined, 'Salon Address', '247, near HDFC Bank, Scheme No 171, Indore, MP'),
                    const Divider(height: 20),
                    _buildRow(Icons.receipt_outlined, 'Advance Paid', '₹${booking.advancePaid.toStringAsFixed(2)} (Razorpay)'),
                    const Divider(height: 20),
                    _buildRow(Icons.account_balance_wallet_outlined, 'Due at Salon', '₹${remainingPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=247,+near+HDFC+Bank,+Scheme+No+171,+Indore,+Madhya+Pradesh+452010');
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.directions, color: AppColors.primary),
                      label: const Text('Get Directions'),
                    ),
                  ),
                  if (booking.bookingStatus == 'confirmed') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirestoreService().updateBookingStatus(booking.id, 'cancelled');
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Appointment cancelled')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                        label: const Text('Cancel Booking'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    ],
  );
}
