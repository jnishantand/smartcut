import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../customer/customer_main_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;

  const SignUpScreen({super.key, required this.phoneNumber});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _completeSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save complete profile to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phoneNumber': widget.phoneNumber,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'notificationSettings': {
            'bookingUpdates': true,
            'appointmentReminders': true,
            'salonAnnouncements': true,
            'promotions': false,
          }
        });

        // Navigate to Customer Home
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false, // Force them to finish signup
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_outline, size: 48, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'Just one more step',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let us know who you are so we can personalize your experience.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 48),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'John Doe',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'john@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  initialValue: widget.phoneNumber,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  enabled: false, // Locked to what they verified
                ),
                const SizedBox(height: 48),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeSignUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Complete Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
