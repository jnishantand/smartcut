import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to view notifications.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final timestamp = data['createdAt'] as Timestamp?;
              final dateTime = timestamp?.toDate() ?? DateTime.now();
              
              // Formatting a simple date string
              final timeString = "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

              return ListTile(
                leading: _getIconForType(data['type']),
                title: Text(data['title'] ?? 'Notification'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['body'] ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _getIconForType(String? type) {
    switch (type) {
      case 'booking':
        return const Icon(Icons.book_online, color: Colors.blue);
      case 'payment':
        return const Icon(Icons.payment, color: Colors.green);
      case 'reminder':
        return const Icon(Icons.alarm, color: Colors.orange);
      case 'promotion':
        return const Icon(Icons.local_offer, color: Colors.red);
      case 'announcement':
        return const Icon(Icons.campaign, color: Colors.purple);
      default:
        return const Icon(Icons.notifications);
    }
  }
}
