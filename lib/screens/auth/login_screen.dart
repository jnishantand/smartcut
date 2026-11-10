import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../customer/home/customer_home_screen.dart'; // temporary navigation

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+1 234 567 8900',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () {
                  // Navigate to home (simulated auth)
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => const CustomerHomeScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Send OTP'),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
