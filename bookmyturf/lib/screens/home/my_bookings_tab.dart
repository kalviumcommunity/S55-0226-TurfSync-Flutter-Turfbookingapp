import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../theme.dart';
import '../../widgets/booking_card.dart';

class MyBookingsTab extends StatelessWidget {
  const MyBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final bookingSvc = context.read<BookingService>();

    if (!auth.isLoggedIn) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your bookings')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('My Bookings'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<TurfBooking>>(
        stream: bookingSvc.streamMyBookings(auth.currentUser!.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snap.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book a turf to get started!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final upcoming = bookings
              .where((b) =>
                  b.date.isAfter(DateTime.now()) &&
                  b.status != BookingStatus.cancelled)
              .toList();
          final past = bookings
              .where((b) =>
                  b.date.isBefore(DateTime.now()) ||
                  b.status == BookingStatus.cancelled)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: 'Upcoming (${upcoming.length})'),
                const SizedBox(height: 8),
                ...upcoming.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BookingCard(
                        booking: b,
                        showCancelButton: true,
                        onCancel: () => _cancelBooking(context, b),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (past.isNotEmpty) ...[
                _SectionHeader(title: 'Past & Cancelled'),
                const SizedBox(height: 8),
                ...past.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BookingCard(booking: b, showCancelButton: false),
                    )),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context, TurfBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Cancel your booking at ${booking.turfName} on ${booking.timeSlot}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final err =
          await context.read<BookingService>().cancelBooking(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Booking cancelled successfully'),
            backgroundColor: err == null ? Colors.green : AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.darkGreen,
      ),
    );
  }
}
