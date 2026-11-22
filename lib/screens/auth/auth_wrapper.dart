import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login_screen.dart';
import '../customer/customer_main_screen.dart';
import '../admin/admin_main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // If Provider is currently loading the Firebase session, show a spinner
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user is logged in, show Login
        if (userProvider.userProfile == null) {
          return const LoginScreen();
        }

        // User is logged in, route them based on their role
        if (userProvider.userProfile!.role == 'admin') {
          return const AdminMainScreen();
        } else {
          return const CustomerMainScreen();
        }
      },
    );
  }
}
