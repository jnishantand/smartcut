import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../models/salon_service.dart';

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Service',
            onPressed: () => _showAddEditServiceDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<SalonService>>(
        stream: FirestoreService().getAllServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No Services Added Yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditServiceDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Service'),
                  ),
                ],
              ),
            );
          }

          final services = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: service.isActive 
                          ? AppColors.primary.withOpacity(0.1) 
                          : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.content_cut,
                      color: service.isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    service.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: service.isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${service.category} • ${service.durationMinutes} mins\nPrice: ₹${service.price.toStringAsFixed(0)} | Advance: ₹${service.advanceRequired.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: service.isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          FirestoreService().updateService(service.id, {'isActive': val});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () => _showAddEditServiceDialog(context, service: service),
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
        onPressed: () => _showAddEditServiceDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddEditServiceDialog(BuildContext context, {SalonService? service}) {
    final nameController = TextEditingController(text: service?.name ?? '');
    final categoryController = TextEditingController(text: service?.category ?? 'Haircuts');
    final durationController = TextEditingController(text: service?.durationMinutes.toString() ?? '30');
    final priceController = TextEditingController(text: service?.price.toStringAsFixed(0) ?? '200');
    final advanceController = TextEditingController(text: service?.advanceRequired.toStringAsFixed(0) ?? '50');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(service == null ? 'Add New Service' : 'Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name', hintText: 'e.g. Skin Fade Haircut'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category', hintText: 'Haircuts / Beard / Spa'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (Minutes)', hintText: '30'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Total Price (₹)', hintText: '250'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: advanceController,
                  decoration: const InputDecoration(labelText: 'Advance Deposit (₹)', hintText: '50'),
                  keyboardType: TextInputType.number,
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

                final category = categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim();
                final duration = int.tryParse(durationController.text) ?? 30;
                final price = double.tryParse(priceController.text) ?? 200.0;
                final advance = double.tryParse(advanceController.text) ?? 50.0;

                if (service == null) {
                  // Add new service
                  await FirestoreService().addService(SalonService(
                    id: '',
                    name: name,
                    category: category,
                    durationMinutes: duration,
                    price: price,
                    advanceRequired: advance,
                    isActive: true,
                  ));
                } else {
                  // Update existing service
                  await FirestoreService().updateService(service.id, {
                    'name': name,
                    'category': category,
                    'durationMinutes': duration,
                    'price': price,
                    'advanceRequired': advance,
                  });
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(service == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
