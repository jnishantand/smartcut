import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../models/booking.dart';

class AdminPaymentHistoryScreen extends StatefulWidget {
  const AdminPaymentHistoryScreen({super.key});

  @override
  State<AdminPaymentHistoryScreen> createState() => _AdminPaymentHistoryScreenState();
}

class _AdminPaymentHistoryScreenState extends State<AdminPaymentHistoryScreen> {
  String _filterMode = 'daily'; // 'daily', 'monthly', 'all'
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment & Revenue History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final allBookings = docs.map((doc) => Booking.fromFirestore(doc)).toList();

                  // Filter bookings based on selected mode
                  final filteredBookings = allBookings.where((b) {
                    if (_filterMode == 'daily') {
                      return b.appointmentDate.year == _selectedDate.year &&
                             b.appointmentDate.month == _selectedDate.month &&
                             b.appointmentDate.day == _selectedDate.day;
                    } else if (_filterMode == 'monthly') {
                      return b.appointmentDate.year == _selectedYear &&
                             b.appointmentDate.month == _selectedMonth;
                    } else {
                      return true; // All Time
                    }
                  }).toList();

                  // Calculate metrics
                  double totalRevenue = 0;
                  for (var b in filteredBookings) {
                    if (b.bookingStatus == 'confirmed' || b.bookingStatus == 'completed') {
                      totalRevenue += b.advancePaid;
                    }
                  }

                  return Column(
                    children: [
                      _buildSummaryCards(filteredBookings.length, totalRevenue),
                      Expanded(
                        child: filteredBookings.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textSecondary),
                                    const SizedBox(height: 16),
                                    Text('No transactions found', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 4),
                                    const Text('Try changing your date or month filter above.', style: TextStyle(color: AppColors.textSecondary)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(24.0),
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = filteredBookings[index];
                                  final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt);

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 18,
                                                    backgroundColor: AppColors.secondary,
                                                    child: Text(
                                                      booking.customerName.isNotEmpty ? booking.customerName[0].toUpperCase() : 'C',
                                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                      Text('#${booking.id}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '₹${booking.advancePaid.toStringAsFixed(0)}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(booking.serviceName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                                  const SizedBox(height: 2),
                                                  Text('Stylist: ${booking.staffName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    booking.bookingStatus.toUpperCase(),
                                                    style: TextStyle(
                                                      color: booking.bookingStatus == 'confirmed' ? AppColors.success : (booking.bookingStatus == 'completed' ? AppColors.primary : AppColors.error),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip('Daily', 'daily'),
              const SizedBox(width: 8),
              _buildFilterChip('Monthly', 'monthly'),
              const SizedBox(width: 8),
              _buildFilterChip('All Time', 'all'),
            ],
          ),
          const SizedBox(height: 16),
          if (_filterMode == 'daily') ...[
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ] else if (_filterMode == 'monthly') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_months[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                    }
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: [2025, 2026, 2027].map((y) {
                    return DropdownMenuItem(
                      value: y,
                      child: Text('$y', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
                    }
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String mode) {
    final isSelected = _filterMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterMode = mode;
          });
        }
      },
    );
  }

  Widget _buildSummaryCards(int count, double totalRevenue) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('₹${totalRevenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transactions', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
