import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../theme.dart';

class BookingCard extends StatelessWidget {
  final TurfBooking booking;
  final bool showCancelButton;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.showCancelButton,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = booking.status == BookingStatus.cancelled
        ? Colors.grey
        : booking.status == BookingStatus.confirmed
            ? AppTheme.primaryGreen
            : AppTheme.warningAmber;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          // Left color accent
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stadium_outlined, size: 14, color: AppTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.turfName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.darkGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      booking.timeSlot,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEE, MMM d').format(booking.date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.group_outlined, size: 12, color: AppTheme.accentGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.teamName.isNotEmpty ? booking.teamName : booking.userName,
                        style: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Chip(
                label: Text(booking.sport, style: const TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              if (showCancelButton && onCancel != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.errorRed,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
