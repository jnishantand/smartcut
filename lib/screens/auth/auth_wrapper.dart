import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../customer/customer_main_screen.dart';
import '../admin/admin_main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 1. If Provider is currently loading, show spinner
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = FirebaseAuth.instance.currentUser;

        // 2. If no user is logged into Firebase Auth, show LoginScreen
        if (currentUser == null) {
          return const LoginScreen();
        }

        // 3. User IS logged into Firebase Auth, but has NO Firestore profile document yet
        if (userProvider.userProfile == null) {
          return SignUpScreen(
            phoneNumber: currentUser.phoneNumber ?? '',
            email: currentUser.email,
            name: currentUser.displayName,
          );
        }

        // 4. User is logged in and has a profile -> Route based on role
        if (userProvider.userProfile!.role == 'admin') {
          return const AdminMainScreen();
        } else {
          return const CustomerMainScreen();
        }
      },
    );
  }
}
