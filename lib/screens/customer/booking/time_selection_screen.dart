import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'booking_summary_screen.dart'; // We'll create this next

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
  final List<String> _eveningSlots = ['04:30 PM', '05:15 PM', '06:00 PM'];
  
  final List<String> _bookedSlots = ['10:30 AM', '01:30 PM']; // Simulated unavailable slots

  @override
  Widget build(BuildContext context) {
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
            child: ListView(
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
                          'Appointments must be booked at least 60 minutes in advance.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Text('Morning', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _buildTimeGrid(_morningSlots),
                
                const SizedBox(height: 32),
                Text('Afternoon', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _buildTimeGrid(_afternoonSlots),
                
                const SizedBox(height: 32),
                Text('Evening', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                _buildTimeGrid(_eveningSlots),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
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
        itemCount: 7, // Next 7 days
        itemBuilder: (context, index) {
          final isSelected = _selectedDateIndex == index;
          // Simple mock dates
          final day = 12 + index; 
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index % 7];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
                _selectedTime = null; // Reset time when date changes
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
                    '$day',
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

  Widget _buildTimeGrid(List<String> slots) {
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
        final time = slots[index];
        final isBooked = _bookedSlots.contains(time);
        final isSelected = _selectedTime == time;
        
        return GestureDetector(
          onTap: isBooked ? null : () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBooked ? AppColors.background : (isSelected ? AppColors.primary : AppColors.surface),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBooked ? Colors.transparent : (isSelected ? AppColors.primary : AppColors.border)
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isBooked ? AppColors.textSecondary.withOpacity(0.5) : (isSelected ? Colors.white : AppColors.textPrimary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                decoration: isBooked ? TextDecoration.lineThrough : null,
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
        onPressed: _selectedTime == null ? null : () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const BookingSummaryScreen())
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
