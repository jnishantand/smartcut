import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/booking_provider.dart';
import 'booking_summary_screen.dart';

class TimeSelectionScreen extends StatefulWidget {
  const TimeSelectionScreen({super.key});

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  int _selectedDateIndex = 0;
  String? _selectedTime;

  final List<String> _morningSlots = ['09:00 AM', '09:45 AM', '10:30 AM', '11:15 AM'];
  final List<String> _afternoonSlots = ['12:00 PM', '12:45 PM', '01:30 PM', '02:15 PM', '03:00 PM', '03:45 PM'];
  final List<String> _eveningSlots = ['04:30 PM', '05:15 PM', '06:00 PM', '06:45 PM', '07:30 PM', '08:15 PM'];

  DateTime get _selectedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(days: _selectedDateIndex));
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDate;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateSelector(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('bookingStatus', isEqualTo: 'confirmed')
                  .where('appointmentDate', isGreaterThanOrEqualTo: startOfDay)
                  .where('appointmentDate', isLessThanOrEqualTo: endOfDay)
                  .snapshots(),
              builder: (context, snapshot) {
                // Count bookings per slot
                final Map<String, int> slotBookingCounts = {};
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final slot = data['timeSlot'] as String?;
                    if (slot != null) {
                      slotBookingCounts[slot] = (slotBookingCounts[slot] ?? 0) + 1;
                    }
                  }
                }

                // A slot is fully booked if 4 bookings exist for that slot (4 chairs)
                final Set<String> fullyBookedSlots = {};
                slotBookingCounts.forEach((slot, count) {
                  if (count >= 4) {
                    fullyBookedSlots.add(slot);
                  }
                });

                return ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing real-time availability for ${DateFormat('EEE, dd MMM').format(selectedDate)}.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text('Morning', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _buildTimeGrid(_morningSlots, fullyBookedSlots, selectedDate),

                    const SizedBox(height: 32),
                    Text('Afternoon', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _buildTimeGrid(_afternoonSlots, fullyBookedSlots, selectedDate),

                    const SizedBox(height: 32),
                    Text('Evening', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _buildTimeGrid(_eveningSlots, fullyBookedSlots, selectedDate),
                  ],
                );
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7, // Next 7 real calendar days
        itemBuilder: (context, index) {
          final isSelected = _selectedDateIndex == index;
          final date = today.add(Duration(days: index));
          final dayName = DateFormat('EEE').format(date); // Mon, Tue, etc.
          final dayNum = DateFormat('d').format(date); // 1, 2, 3...

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
                _selectedTime = null; // Reset time selection when date changes
              });
            },
            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid(List<String> slots, Set<String> fullyBookedSlots, DateTime selectedDate) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final timeStr = slots[index];
        bool isUnavailable = fullyBookedSlots.contains(timeStr);

        // If today, check if time slot is already past
        if (isToday) {
          try {
            final parsedTime = DateFormat('hh:mm a').parse(timeStr);
            final slotDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            if (slotDateTime.isBefore(now)) {
              isUnavailable = true; // Disable past hours for today
            }
          } catch (_) {}
        }

        final isSelected = _selectedTime == timeStr;

        return GestureDetector(
          onTap: isUnavailable
              ? null
              : () {
                  setState(() {
                    _selectedTime = timeStr;
                  });
                },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isUnavailable
                  ? AppColors.background
                  : (isSelected ? AppColors.primary : AppColors.surface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnavailable
                    ? Colors.transparent
                    : (isSelected ? AppColors.primary : AppColors.border),
              ),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                color: isUnavailable
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : (isSelected ? Colors.white : AppColors.textPrimary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                decoration: isUnavailable ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedTime == null
            ? null
            : () {
                final bookingDate = _selectedDate;
                context.read<BookingProvider>().selectDateTime(bookingDate, _selectedTime!);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingSummaryScreen()),
                );
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text('Continue to Summary'),
      ),
    );
  }
}
