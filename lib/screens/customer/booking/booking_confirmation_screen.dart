import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../home/customer_home_screen.dart'; // To route back to home

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.white, size: 80),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Booking Confirmed!',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your appointment has been successfully booked. You will receive a notification reminder 15 minutes before your time.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
                      // Ticket details
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            _buildTicketRow('Booking ID', '#SC-8492'),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                            _buildTicketRow('Service', 'Classic Haircut'),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                            _buildTicketRow('Date', 'Tue, 12 Nov 2024'),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                            _buildTicketRow('Time', '09:45 AM'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Return to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTicketRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
