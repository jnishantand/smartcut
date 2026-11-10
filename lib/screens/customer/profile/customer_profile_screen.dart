import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../notifications/notification_preferences_screen.dart';
import '../../auth/login_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 32),
          _buildSettingsSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.person, size: 50, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Alex Johnson',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          '+1 234 567 8900',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Settings', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildListTile(
          context: context,
          icon: Icons.payment,
          title: 'Payment History',
          onTap: () {},
        ),
        _buildListTile(
          context: context,
          icon: Icons.notifications_outlined,
          title: 'Notification Preferences',
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen())
            );
          },
        ),
        const SizedBox(height: 24),
        Text('Support', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildListTile(
          context: context,
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          onTap: () {},
        ),
        _buildListTile(
          context: context,
          icon: Icons.info_outline,
          title: 'About SmartCut',
          onTap: () {},
        ),
        const SizedBox(height: 24),
        _buildListTile(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          textColor: AppColors.error,
          iconColor: AppColors.error,
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
