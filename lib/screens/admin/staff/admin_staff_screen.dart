import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../models/staff.dart';

class AdminStaffScreen extends StatelessWidget {
  const AdminStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Barbers & Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            tooltip: 'Add Barber',
            onPressed: () => _showAddEditStaffDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Staff>>(
        stream: FirestoreService().getAllStaff(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No Barbers Added Yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditStaffDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Barber'),
                  ),
                ],
              ),
            );
          }

          final staffList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: staff.isActive 
                        ? AppColors.secondary 
                        : AppColors.textSecondary.withOpacity(0.2),
                    child: Text(
                      staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: staff.isActive ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  title: Text(
                    staff.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: staff.isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${staff.role} • ${staff.experienceYears} yrs exp • ★ ${staff.rating.toStringAsFixed(1)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: staff.isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          FirestoreService().updateStaff(staff.id, {'isActive': val});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () => _showAddEditStaffDialog(context, staff: staff),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditStaffDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Barber', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddEditStaffDialog(BuildContext context, {Staff? staff}) {
    final nameController = TextEditingController(text: staff?.name ?? '');
    final roleController = TextEditingController(text: staff?.role ?? 'Master Barber');
    final ratingController = TextEditingController(text: staff?.rating.toStringAsFixed(1) ?? '4.9');
    final expController = TextEditingController(text: staff?.experienceYears.toString() ?? '5');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(staff == null ? 'Add New Barber' : 'Edit Barber'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Barber Name', hintText: 'e.g. Alex Johnson'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Specialization / Role', hintText: 'Master Barber / Fade Specialist'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expController,
                  decoration: const InputDecoration(labelText: 'Experience (Years)', hintText: '5'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'Rating (1.0 - 5.0)', hintText: '4.9'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final role = roleController.text.trim().isEmpty ? 'Barber' : roleController.text.trim();
                final rating = double.tryParse(ratingController.text) ?? 4.8;
                final exp = int.tryParse(expController.text) ?? 3;

                if (staff == null) {
                  // Add new barber
                  await FirestoreService().addStaff(Staff(
                    id: '',
                    name: name,
                    role: role,
                    rating: rating,
                    experienceYears: exp,
                    isActive: true,
                  ));
                } else {
                  // Update existing barber
                  await FirestoreService().updateStaff(staff.id, {
                    'name': name,
                    'role': role,
                    'rating': rating,
                    'experienceYears': exp,
                  });
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(staff == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
