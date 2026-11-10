import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SendCustomNotificationScreen extends StatefulWidget {
  const SendCustomNotificationScreen({super.key});

  @override
  State<SendCustomNotificationScreen> createState() =>
      _SendCustomNotificationScreenState();
}

class _SendCustomNotificationScreenState
    extends State<SendCustomNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  String _audienceType = 'all'; // 'all', 'promotional_opt_in'
  bool _isSending = false;

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Call Firebase Cloud Function
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendAdminNotification');
      
      await callable.call(<String, dynamic>{
        'title': _titleController.text,
        'body': _bodyController.text,
        'audience': _audienceType,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending notification: $e')),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Custom Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notification Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notification Body',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _audienceType,
                decoration: const InputDecoration(
                  labelText: 'Target Audience',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('All Users (Announcements)'),
                  ),
                  DropdownMenuItem(
                    value: 'promotional_opt_in',
                    child: Text('Only Promotional Opt-ins (Offers)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _audienceType = val;
                    });
                  }
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSending ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Notification Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
