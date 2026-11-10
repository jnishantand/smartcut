import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (usually Android only)
          // We can handle auto-sign in here if needed, but usually we just let the user 
          // type it in on the next screen anyway to keep the flow consistent, or we can sign in directly.
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification Failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                verificationId: verificationId,
                phoneNumber: phone,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.content_cut, size: 48, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Welcome to SmartCut',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to book your next appointment or manage your salon.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+1 234 567 8900',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyPhone,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
