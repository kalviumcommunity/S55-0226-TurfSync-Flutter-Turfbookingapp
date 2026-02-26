import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../theme.dart';

class BookingFormScreen extends StatefulWidget {
  final Turf turf;
  const BookingFormScreen({super.key, required this.turf});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int? _selectedStartHour;
  List<Map<String, dynamic>> _slots = [];
  bool _loadingSlots = false;
  bool _submitting = false;
  final _notesCtrl = TextEditingController();
  String _selectedSport = '';

  @override
  void initState() {
    super.initState();
    _selectedSport =
        widget.turf.sports.isNotEmpty ? widget.turf.sports.first : 'Football';
    _loadSlots();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSlots() async {
    setState(() => _loadingSlots = true);
    final svc = context.read<BookingService>();
    _slots = await svc.getAvailableSlots(widget.turf.id, _selectedDate);
    setState(() {
      _loadingSlots = false;
      _selectedStartHour = null;
    });
  }

  Future<void> _confirmBooking() async {
    if (_selectedStartHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) return;

    setState(() => _submitting = true);

    final slot = _slots.firstWhere((s) => s['startHour'] == _selectedStartHour);
    final booking = TurfBooking(
      id: '',
      turfId: widget.turf.id,
      turfName: widget.turf.name,
      userId: auth.currentUser!.uid,
      userName: auth.userName ?? 'Unknown',
      userEmail: auth.currentUser!.email ?? '',
      teamName: auth.teamName ?? '',
      sport: _selectedSport,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedStartHour!,
      ),
      timeSlot: slot['label'],
      startHour: _selectedStartHour!,
      endHour: _selectedStartHour! + 1,
      status: BookingStatus.confirmed,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      createdAt: DateTime.now(),
    );

    final err = await context.read<BookingService>().createBooking(booking);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Refresh slots to show updated availability
      _loadSlots();
    } else {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final slot = _slots.firstWhere((s) => s['startHour'] == _selectedStartHour);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Confirmed! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _ConfirmRow(
                        icon: Icons.stadium_rounded,
                        label: 'Turf',
                        value: widget.turf.name),
                    const Divider(height: 16),
                    _ConfirmRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: DateFormat('EEE, MMM d').format(_selectedDate)),
                    const Divider(height: 16),
                    _ConfirmRow(
                        icon: Icons.access_time_rounded,
                        label: 'Slot',
                        value: slot['label']),
                    const Divider(height: 16),
                    _ConfirmRow(
                        icon: Icons.sports_soccer_rounded,
                        label: 'Sport',
                        value: _selectedSport),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: Text('Book ${widget.turf.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Date
            _StepCard(
              step: 1,
              title: 'Select Date',
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _selectedDate,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDate),
                onDaySelected: (sel, foc) {
                  setState(() => _selectedDate = sel);
                  _loadSlots();
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
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Select Sport
            _StepCard(
              step: 2,
              title: 'Select Sport',
              child: Wrap(
                spacing: 8,
                children: widget.turf.sports.map((s) {
                  final selected = _selectedSport == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedSport = s),
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Select Time Slot
            _StepCard(
              step: 3,
              title: 'Choose Time Slot',
              subtitle: 'Green = available, Red = booked',
              child: _loadingSlots
                  ? const Center(
                      child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ))
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.6,
                      ),
                      itemCount: _slots.length,
                      itemBuilder: (_, i) {
                        final slot = _slots[i];
                        final isBooked = slot['isBooked'] as bool;
                        final isSelected =
                            _selectedStartHour == slot['startHour'];

                        Color bgColor;
                        Color textColor;
                        if (isBooked) {
                          bgColor = AppTheme.errorRed.withOpacity(0.1);
                          textColor = AppTheme.errorRed;
                        } else if (isSelected) {
                          bgColor = AppTheme.primaryGreen;
                          textColor = Colors.white;
                        } else {
                          bgColor = AppTheme.accentGreen.withOpacity(0.1);
                          textColor = AppTheme.darkGreen;
                        }

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () => setState(
                                  () => _selectedStartHour = slot['startHour']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : isBooked
                                        ? AppTheme.errorRed.withOpacity(0.3)
                                        : AppTheme.accentGreen.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot['label'].toString().split('–').first.trim(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isBooked)
                                  Text(
                                    'BOOKED',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                if (isSelected && !isBooked)
                                  const Icon(Icons.check_circle_rounded,
                                      size: 12, color: Colors.white),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Step 4: Notes
            _StepCard(
              step: 4,
              title: 'Additional Notes (Optional)',
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Team match, practice session, tournament...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFFDDE8E2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary
            if (_selectedStartHour != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.1),
                      AppTheme.accentGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.turf.name}\n${DateFormat('EEE, MMM d').format(_selectedDate)}\n${_slots.firstWhere((s) => s['startHour'] == _selectedStartHour)['label']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text(
                              '₹${widget.turf.pricePerHour.toInt()}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Book button
            ElevatedButton.icon(
              onPressed: _submitting ? null : _confirmBooking,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.bookmark_add_rounded),
              label: Text(_submitting ? 'Confirming...' : 'Confirm Booking'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String? subtitle;
  final Widget child;

  const _StepCard({
    required this.step,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
