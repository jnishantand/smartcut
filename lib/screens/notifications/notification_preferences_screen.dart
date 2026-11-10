import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final user = FirebaseAuth.instance.currentUser;
  
  bool _isLoading = true;
  bool _bookingUpdates = true; // Always true, not toggleable usually, but showing for UI completeness
  bool _appointmentReminders = true;
  bool _salonAnnouncements = true;
  bool _promotions = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (user == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
          
      if (doc.exists && doc.data()!.containsKey('notificationSettings')) {
        final settings = doc.data()!['notificationSettings'] as Map<String, dynamic>;
        setState(() {
          _bookingUpdates = settings['bookingUpdates'] ?? true;
          _appointmentReminders = settings['appointmentReminders'] ?? true;
          _salonAnnouncements = settings['salonAnnouncements'] ?? true;
          _promotions = settings['promotions'] ?? false;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (user == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'notificationSettings': {
          'bookingUpdates': _bookingUpdates,
          'appointmentReminders': _appointmentReminders,
          'salonAnnouncements': _salonAnnouncements,
          'promotions': _promotions,
        }
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Preferences')),
        body: const Center(child: Text('Please log in to manage preferences.')),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Preferences')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manage what notifications you receive.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Booking & Payment Updates'),
            subtitle: const Text('Important transactional updates.'),
            value: _bookingUpdates,
            onChanged: null, // Disabled because these are essential
          ),
          SwitchListTile(
            title: const Text('Appointment Reminders'),
            subtitle: const Text('Get a reminder 15 mins before.'),
            value: _appointmentReminders,
            onChanged: (val) {
              setState(() => _appointmentReminders = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Salon Announcements'),
            subtitle: const Text('Changes to opening hours, etc.'),
            value: _salonAnnouncements,
            onChanged: (val) {
              setState(() => _salonAnnouncements = val);
              _savePreferences();
            },
          ),
          SwitchListTile(
            title: const Text('Offers & Promotions'),
            subtitle: const Text('Discounts and available slot alerts.'),
            value: _promotions,
            onChanged: (val) {
              setState(() => _promotions = val);
              _savePreferences();
            },
          ),
        ],
      ),
    );
  }
}
