import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../customer/customer_main_screen.dart';
import '../admin/admin_main_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign the user in (or link) with the credential
      UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _checkUserRoleAndNavigate(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Invalid OTP')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<void> _checkUserRoleAndNavigate(User user) async {
    try {
      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Create new customer profile
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phoneNumber': widget.phoneNumber,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'notificationSettings': {
            'bookingUpdates': true,
            'appointmentReminders': true,
            'salonAnnouncements': true,
            'promotions': false,
          }
        });
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
            (route) => false,
          );
        }
      } else {
        // Existing user, check role
        final data = userDoc.data() as Map<String, dynamic>?;
        final role = data?['role'] ?? 'customer';
        
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminMainScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'A 6-digit code has been sent to ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: '6-digit OTP',
                  hintText: '123456',
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify & Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
