import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../models/booking.dart';
import '../../../services/firestore_service.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final service = bookingProvider.selectedService;
    
    if (service == null) {
      return const Scaffold(body: Center(child: Text('Error: No service selected')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('\$${service.advanceRequired.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                
                _buildPaymentMethod(0, Icons.credit_card, 'Credit / Debit Card', '**** **** **** 4242'),
                const SizedBox(height: 12),
                _buildPaymentMethod(1, Icons.apple, 'Apple Pay', ''),
                const SizedBox(height: 12),
                _buildPaymentMethod(2, Icons.account_balance_wallet, 'Add New Card', ''),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedMethod == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ]
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
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
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: _isProcessing 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Confirm Payment'),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    final bookingProvider = context.read<BookingProvider>();
    final userProvider = context.read<UserProvider>();
    
    final service = bookingProvider.selectedService!;
    final staffName = bookingProvider.selectedStaffName ?? 'Any Available';
    final staffId = bookingProvider.selectedStaffId ?? 'any';
    final date = bookingProvider.selectedDate!;
    final time = bookingProvider.selectedTime!;
    final profile = userProvider.userProfile;

    // Simulate network delay for payment gateway
    await Future.delayed(const Duration(seconds: 2));

    try {
      final String bookingId = const Uuid().v4().substring(0, 8).toUpperCase();

      final booking = Booking(
        id: bookingId,
        customerId: profile?.uid ?? 'unknown',
        customerName: profile?.name ?? 'Guest',
        serviceId: service.id,
        serviceName: service.name,
        staffId: staffId,
        staffName: staffName,
        appointmentDate: date,
        timeSlot: time,
        totalAmount: service.price,
        advancePaid: service.advanceRequired,
        paymentStatus: 'advance_paid',
        bookingStatus: 'confirmed',
        createdAt: DateTime.now(),
      );

      await FirestoreService().createBooking(booking);

      if (mounted) {
        setState(() => _isProcessing = false);
        // Reset the cart
        bookingProvider.reset();
        
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => BookingConfirmationScreen(booking: booking)),
          (route) => false // Clear stack to prevent going back to payment
        );
      }
    } catch(e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete booking: $e')),
        );
      }
    }
  }
}
