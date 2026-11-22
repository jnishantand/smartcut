import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../theme/app_colors.dart';
import '../../auth/auth_wrapper.dart';
import '../admin_notification_management_screen.dart';
import '../services/admin_services_screen.dart';
import '../staff/admin_staff_screen.dart';
import 'admin_business_hours_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionTitle(context, 'Salon Management'),
          _buildSettingsTile(context, Icons.cut, 'Service Management', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminServicesScreen()));
          }),
          _buildSettingsTile(context, Icons.people, 'Staff Management (Barbers)', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStaffScreen()));
          }),
          _buildSettingsTile(context, Icons.business, 'Business Hours & Time Slots', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBusinessHoursScreen()));
          }),
          
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Operations & Rules'),
          _buildSettingsTile(context, Icons.attach_money, 'Payment & Deposit Settings', () {}),
          _buildSettingsTile(context, Icons.notifications_active, 'Notification Dashboard', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationManagementScreen()));
          }),
          
          const SizedBox(height: 32),
          _buildSettingsTile(context, Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
            try {
              await GoogleSignIn.instance.signOut();
            } catch (_) {}
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            }
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isDestructive ? color : AppColors.textPrimary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
