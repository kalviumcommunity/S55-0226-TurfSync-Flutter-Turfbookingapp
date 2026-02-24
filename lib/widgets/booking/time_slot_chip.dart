import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/time_slot_model.dart';

/// A chip widget representing a time slot.
/// Shows different colors based on availability.
class TimeSlotChip extends StatelessWidget {
  final TimeSlotModel slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.slot,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBooked = slot.isBooked;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isBooked) {
      backgroundColor = AppColors.bookedSlot;
      textColor = Colors.red.shade800;
      borderColor = Colors.red.shade300;
    } else if (isSelected) {
      backgroundColor = AppColors.selectedSlot;
      textColor = Colors.white;
      borderColor = AppColors.primaryGreen;
    } else {
      backgroundColor = AppColors.availableSlot;
      textColor = AppColors.primaryGreenDark;
      borderColor = AppColors.primaryGreenLight;
    }

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${slot.startTime}\n${slot.endTime}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isBooked ? 'Booked' : (isSelected ? 'Selected' : 'Available'),
              style: TextStyle(
                fontSize: 10,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
