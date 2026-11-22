import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../customer/customer_main_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? email;
  final String? name;

  const SignUpScreen({super.key, required this.phoneNumber, this.email, this.name});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.name != null) _nameController.text = widget.name!;
    if (widget.email != null) _emailController.text = widget.email!;
    if (widget.phoneNumber.isNotEmpty) {
      _phoneController.text = widget.phoneNumber;
    }
  }

  Future<void> _completeSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final phone = _phoneController.text.trim();
        final isAdmin = phone.contains('9424894244') || (widget.phoneNumber.contains('9424894244'));
        final role = isAdmin ? 'admin' : 'customer';

        // Save complete profile to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'phoneNumber': phone,
          'name': _nameController.text.trim().isEmpty ? (isAdmin ? 'Salon Admin' : 'Customer') : _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'notificationSettings': {
            'bookingUpdates': true,
            'appointmentReminders': true,
            'salonAnnouncements': true,
            'promotions': false,
          }
        });

        // Refresh provider profile state so AuthWrapper automatically transitions
        if (mounted) {
          await context.read<UserProvider>().refreshProfile();
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 64,
                  height: 64,
                ),
              ),
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
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+1 234 567 8900',
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: widget.phoneNumber.isEmpty, // Only editable if not verified via Phone Auth
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
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
