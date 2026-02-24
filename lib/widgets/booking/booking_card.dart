import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/booking_status.dart';
import '../../core/utils/date_utils.dart';
import '../../models/booking_model.dart';

/// Displays a booking as a card with status indicator.
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final bool showActions;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.onCancel,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.turfName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Details ───
              _buildInfoRow(
                Icons.person,
                booking.userName,
                context,
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                Icons.calendar_today,
                AppDateUtils.formatDate(booking.date),
                context,
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                Icons.access_time,
                '${booking.startTime} – ${booking.endTime}',
                context,
              ),

              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildInfoRow(Icons.note, booking.notes!, context),
              ],

              if (booking.rejectionReason != null &&
                  booking.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.info_outline,
                  'Reason: ${booking.rejectionReason}',
                  context,
                  color: AppColors.error,
                ),
              ],

              // ─── Action Buttons ───
              if (showActions && booking.status == BookingStatus.pending) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onReject != null)
                      TextButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, color: AppColors.error),
                        label: const Text('Reject',
                            style: TextStyle(color: AppColors.error)),
                      ),
                    const SizedBox(width: 8),
                    if (onApprove != null)
                      ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.approvedColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                  ],
                ),
              ],

              if (onCancel != null &&
                  booking.status == BookingStatus.pending) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppColors.error),
                    label: const Text('Cancel Booking',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    switch (booking.status) {
      case BookingStatus.pending:
        chipColor = AppColors.pendingColor;
        break;
      case BookingStatus.approved:
        chipColor = AppColors.approvedColor;
        break;
      case BookingStatus.rejected:
        chipColor = AppColors.rejectedColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        booking.status.displayName,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color ?? Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
