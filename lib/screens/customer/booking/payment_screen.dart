import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
  bool _isProcessing = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

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
                      Text('₹${service.advanceRequired.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Secure Checkout with Razorpay',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Supports UPI, Cards, Netbanking & Wallets',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(service.advanceRequired),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double amount) {
    return SafeArea(
      top: false,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isProcessing 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Pay ₹${amount.toStringAsFixed(2)} via Razorpay'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isProcessing ? null : () => _handlePaymentSuccess(null),
              child: const Text('Simulate Test Payment (Bypass)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    final bookingProvider = context.read<BookingProvider>();
    final userProvider = context.read<UserProvider>();
    
    final service = bookingProvider.selectedService!;
    final profile = userProvider.userProfile;

    // Razorpay requires amounts in the smallest currency sub-unit (e.g. paise, cents).
    // So $10.00 would be 1000 cents.
    final int amountInCents = (service.advanceRequired * 100).toInt();

    var options = {
      'key': 'rzp_test_U34oMk0qZkEFzg', // Using the Test Key from CSV
      'amount': amountInCents,
      'currency': 'INR', // Explicitly setting currency helps bypass some local restrictions on test accounts
      'name': 'Smartcut Salon',
      'description': 'Advance Payment for ${service.name}',
      'prefill': {
        'contact': profile?.phoneNumber ?? '9876543210',
        'email': profile?.email ?? 'test@example.com'
      },
      'theme': {
        'color': '#2457A6' // AppColors.primary hex
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error launching Razorpay: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch payment: $e')),
        );
      }
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse? response) async {
    // Payment Successful - Now save the booking to Firestore
    setState(() => _isProcessing = true);
    
    final bookingProvider = context.read<BookingProvider>();
    final userProvider = context.read<UserProvider>();
    
    final service = bookingProvider.selectedService!;
    final staffName = bookingProvider.selectedStaffName ?? 'Any Available';
    final staffId = bookingProvider.selectedStaffId ?? 'any';
    final date = bookingProvider.selectedDate ?? DateTime.now();
    final time = bookingProvider.selectedTime ?? '10:00 AM';
    final profile = userProvider.userProfile;

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
        bookingProvider.reset();
        
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => BookingConfirmationScreen(booking: booking)),
          (route) => false
        );
      }
    } catch(e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save booking: $e')),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Show wallet message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }
}
