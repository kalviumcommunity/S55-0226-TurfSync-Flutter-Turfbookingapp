import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../theme.dart';
import '../../widgets/booking_card.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTurfId;

  @override
  Widget build(BuildContext context) {
    final bookingSvc = context.watch<BookingService>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Community Schedule'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Turf selector
          if (bookingSvc.turfs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bookingSvc.turfs.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All Turfs'),
                          selected: _selectedTurfId == null,
                          onSelected: (_) =>
                              setState(() => _selectedTurfId = null),
                          selectedColor:
                              AppTheme.primaryGreen.withOpacity(0.15),
                          checkmarkColor: AppTheme.primaryGreen,
                        ),
                      );
                    }
                    final t = bookingSvc.turfs[i - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(t.name.split(' ').first),
                        selected: _selectedTurfId == t.id,
                        onSelected: (_) =>
                            setState(() => _selectedTurfId = t.id),
                        selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                        checkmarkColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Calendar
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.redAccent),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.darkGreen,
                ),
              ),
            ),
          ),

          // Bookings for selected day
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(_selectedDay),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGreen,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _BookingsForDay(
              date: _selectedDay,
              turfId: _selectedTurfId,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsForDay extends StatelessWidget {
  final DateTime date;
  final String? turfId;

  const _BookingsForDay({required this.date, this.turfId});

  @override
  Widget build(BuildContext context) {
    final bookingSvc = context.read<BookingService>();
    final turfs = context.watch<BookingService>().turfs;

    if (turfId != null) {
      // Show for specific turf
      return StreamBuilder<List<TurfBooking>>(
        stream: bookingSvc.streamBookingsForTurfDate(turfId!, date),
        builder: (_, snap) => _BookingList(bookings: snap.data ?? []),
      );
    }

// Show for all turfs
    return StreamBuilder<List<TurfBooking>>(
      stream: bookingSvc.streamAllUpcomingBookings(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allBookings = (snap.data ?? []).where((b) {
          return b.date.year == date.year &&
              b.date.month == date.month &&
              b.date.day == date.day &&
              b.status != BookingStatus.cancelled;
        }).toList();
        return _BookingList(bookings: allBookings);
      },
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<TurfBooking> bookings;
  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_rounded,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No bookings on this day',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            const Text(
              'Turf is available for booking!',
              style: TextStyle(
                  color: AppTheme.primaryGreen, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: bookings.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: BookingCard(booking: bookings[i], showCancelButton: false),
      ),
    );
  }
}
