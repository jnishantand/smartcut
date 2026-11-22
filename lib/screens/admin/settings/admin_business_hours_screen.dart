import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../services/firestore_service.dart';

class AdminBusinessHoursScreen extends StatefulWidget {
  const AdminBusinessHoursScreen({super.key});

  @override
  State<AdminBusinessHoursScreen> createState() => _AdminBusinessHoursScreenState();
}

class _AdminBusinessHoursScreenState extends State<AdminBusinessHoursScreen> {
  final _formKey = GlobalKey<FormState>();
  final _openController = TextEditingController(text: '09:00 AM');
  final _closeController = TextEditingController(text: '08:30 PM');

  List<String> _morningSlots = ['09:00 AM', '09:45 AM', '10:30 AM', '11:15 AM'];
  List<String> _afternoonSlots = ['12:00 PM', '12:45 PM', '01:30 PM', '02:15 PM', '03:00 PM', '03:45 PM'];
  List<String> _eveningSlots = ['04:30 PM', '05:15 PM', '06:00 PM', '06:45 PM', '07:30 PM', '08:15 PM'];

  Set<String> _disabledSlots = {};
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Hours & Slots'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getBusinessHours(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists && !_isLoaded) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            _openController.text = data['openingTime'] ?? '09:00 AM';
            _closeController.text = data['closingTime'] ?? '08:30 PM';
            if (data['disabledSlots'] != null) {
              _disabledSlots = Set<String>.from(data['disabledSlots']);
            }
            if (data['morningSlots'] != null) {
              _morningSlots = List<String>.from(data['morningSlots']);
            }
            if (data['afternoonSlots'] != null) {
              _afternoonSlots = List<String>.from(data['afternoonSlots']);
            }
            if (data['eveningSlots'] != null) {
              _eveningSlots = List<String>.from(data['eveningSlots']);
            }
            _isLoaded = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operating Hours', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _openController,
                          decoration: const InputDecoration(
                            labelText: 'Opening Time',
                            prefixIcon: Icon(Icons.wb_sunny_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _closeController,
                          decoration: const InputDecoration(
                            labelText: 'Closing Time',
                            prefixIcon: Icon(Icons.nights_stay_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Booking Time Slots', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap a time slot to enable or disable it for customer bookings.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  _buildSlotCategory('Morning Slots (9 AM - 12 PM)', _morningSlots),
                  const SizedBox(height: 24),
                  _buildSlotCategory('Afternoon Slots (12 PM - 4 PM)', _afternoonSlots),
                  const SizedBox(height: 24),
                  _buildSlotCategory('Evening Slots (4 PM - 9 PM)', _eveningSlots),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveHoursAndSlots,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Business Hours & Slots'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotCategory(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((slot) {
            final isDisabled = _disabledSlots.contains(slot);
            return FilterChip(
              label: Text(
                slot,
                style: TextStyle(
                  color: isDisabled ? AppColors.textSecondary : AppColors.primary,
                  decoration: isDisabled ? TextDecoration.lineThrough : null,
                  fontWeight: isDisabled ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              selected: !isDisabled,
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _disabledSlots.remove(slot);
                  } else {
                    _disabledSlots.add(slot);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveHoursAndSlots() async {
    setState(() => _isSaving = true);
    try {
      await FirestoreService().updateBusinessHours({
        'openingTime': _openController.text.trim(),
        'closingTime': _closeController.text.trim(),
        'disabledSlots': _disabledSlots.toList(),
        'morningSlots': _morningSlots,
        'afternoonSlots': _afternoonSlots,
        'eveningSlots': _eveningSlots,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business hours & slot availability saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving hours: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
