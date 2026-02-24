import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/booking_status.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';

/// Detail screen for a single booking – shows all info & admin actions.
class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Status Badge ───
            Center(
              child: Chip(
                label: Text(
                  status.displayName.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                side: BorderSide(color: _statusColor(status)),
                backgroundColor: _statusColor(status).withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Turf ───
            _DetailTile(
              icon: Icons.sports_soccer,
              label: 'Turf',
              value: booking.turfName,
            ),

            // ─── User ───
            _DetailTile(
              icon: Icons.person,
              label: 'Booked By',
              value: booking.userName,
            ),

            // ─── Date ───
            _DetailTile(
              icon: Icons.calendar_today,
              label: 'Date',
              value: utils.AppDateUtils.formatDate(booking.date),
            ),

            // ─── Time ───
            _DetailTile(
              icon: Icons.access_time,
              label: 'Time',
              value: '${booking.startTime} – ${booking.endTime}',
            ),

            // ─── Notes ───
            if (booking.notes != null && booking.notes!.isNotEmpty)
              _DetailTile(
                icon: Icons.note,
                label: 'Notes',
                value: booking.notes!,
              ),

            // ─── Rejection Reason ───
            if (booking.rejectionReason != null &&
                booking.rejectionReason!.isNotEmpty)
              _DetailTile(
                icon: Icons.block,
                label: 'Rejection Reason',
                value: booking.rejectionReason!,
              ),

            // ─── Created At ───
            _DetailTile(
              icon: Icons.schedule,
              label: 'Submitted',
              value: utils.AppDateUtils.formatDate(booking.createdAt),
            ),

            const SizedBox(height: 32),

            // ─── Admin Actions ───
            if (status == BookingStatus.pending)
              _AdminActions(booking: booking),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.approved:
        return Colors.green;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
    }
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActions extends StatelessWidget {
  final BookingModel booking;
  const _AdminActions({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookProv, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(
              text: AppStrings.approve,
              onPressed: () async {
                final ok = await bookProv.approveBooking(booking.id);
                if (!context.mounted) return;
                if (ok) {
                  ErrorDialog.showSuccess(context, 'Booking approved');
                  Navigator.pop(context);
                }
              },
              isLoading: bookProv.isLoading,
              icon: Icons.check,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: AppStrings.reject,
              isOutlined: true,
              onPressed: () => _showRejectDialog(context, bookProv),
              icon: Icons.close,
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, BookingProvider bookProv) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Booking'),
        content: CustomTextField(
          controller: reasonController,
          label: 'Reason (optional)',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await bookProv.rejectBooking(
                booking.id,
                reason: reasonController.text.trim(),
              );
              if (!context.mounted) return;
              if (ok) {
                ErrorDialog.showSuccess(context, 'Booking rejected');
                Navigator.pop(context);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
