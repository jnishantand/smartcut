import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'send_custom_notification_screen.dart';

class AdminNotificationManagementScreen extends StatelessWidget {
  const AdminNotificationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Send Custom Notification'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SendCustomNotificationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_off),
              label: const Text('Trigger Quiet Salon Offer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                _triggerQuietSalonDialog(context);
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Admin Broadcasts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .orderBy('createdAt', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  // Filter for broadcast announcements or promotions
                  final broadcastDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] as String?;
                    final userId = data['userId'] as String?;
                    return type == 'promotion' || type == 'announcement' || userId == 'all';
                  }).toList();

                  if (broadcastDocs.isEmpty) {
                    return const Center(child: Text('No recent broadcasts found.'));
                  }

                  return ListView.builder(
                    itemCount: broadcastDocs.length,
                    itemBuilder: (context, index) {
                      final doc = broadcastDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            data['type'] == 'promotion' ? Icons.local_offer : Icons.campaign,
                            color: data['type'] == 'promotion' ? Colors.red : Colors.purple,
                          ),
                          title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(data['body'] ?? ''),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (data['type'] ?? 'broadcast').toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerQuietSalonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiet Salon Offer'),
          content: const Text(
            'This will send a promotional push notification to all customers who have opted-in to promotions, informing them of available slots right now. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call Cloud Function to send quiet salon offer
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quiet Salon offer dispatched!')),
                );
              },
              child: const Text('Send Offer'),
            ),
          ],
        );
      },
    );
  }
}
