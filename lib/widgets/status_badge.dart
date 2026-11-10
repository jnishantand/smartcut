import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SalonStatus { available, busy, fullyBooked }

class StatusBadge extends StatelessWidget {
  final SalonStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case SalonStatus.available:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = "Available";
        icon = Icons.check_circle_outline;
        break;
      case SalonStatus.busy:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = "Busy";
        icon = Icons.access_time;
        break;
      case SalonStatus.fullyBooked:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        label = "Fully Booked";
        icon = Icons.do_not_disturb_alt;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
