import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/booking_status.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../../models/booking_model.dart';
import '../../models/time_slot_model.dart';
import '../../models/turf_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/booking/time_slot_chip.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_dialog.dart';

/// Full booking flow: select date → pick available slot → confirm.
class BookingScreen extends StatefulWidget {
  final TurfModel? turf;

  const BookingScreen({super.key, this.turf});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeSlotModel? _selectedSlot;
  final _notesController = TextEditingController();

  List<TimeSlotModel> _allSlots = [];
  TurfModel? _turf;

  TurfModel get _resolvedTurf => _turf!;

  @override
  void initState() {
    super.initState();
    _turf = widget.turf ?? context.read<TurfProvider>().selectedTurf;
    if (_turf != null) {
      _generateSlots();
      _listenBookedSlots();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Generate all available time slots for the turf.
  void _generateSlots() {
    _allSlots = utils.AppDateUtils.generateTimeSlots(
      startHour: _resolvedTurf.startHour,
      endHour: _resolvedTurf.endHour,
      durationMinutes: _resolvedTurf.slotDuration,
    );
  }

  /// Start listening for booked slots on the selected date.
  void _listenBookedSlots() {
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.listenToBookedSlots(
      _resolvedTurf.id,
      _selectedDate,
    );
  }

  void _onDateSelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDate = selected;
      _selectedSlot = null;
    });
    _listenBookedSlots();
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) return;

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    final now = DateTime.now();
    final booking = BookingModel(
      id: '',
      turfId: _resolvedTurf.id,
      turfName: _resolvedTurf.name,
      userId: authProvider.userId,
      userName: authProvider.userModel?.fullName ?? 'Unknown',
      date: _selectedDate,
      slotKey: _selectedSlot!.slotKey,
      startTime: _selectedSlot!.startTime,
      endTime: _selectedSlot!.endTime,
      status: BookingStatus.pending,
      notes: _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final success = await bookingProvider.createBooking(booking);

    if (!mounted) return;

    if (success) {
      ErrorDialog.showSuccess(context, AppStrings.bookingConfirmed);
      Navigator.pop(context);
    } else if (bookingProvider.errorMessage != null) {
      ErrorDialog.showError(context, bookingProvider.errorMessage!);
      bookingProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_turf == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book a Turf')),
        body: const Center(
          child: Text('No turf selected. Please select a turf first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Book ${_resolvedTurf.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Calendar ───
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: _onDateSelected,
                calendarFormat: CalendarFormat.twoWeeks,
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Date Label ───
            Text(
              'Slots for ${utils.AppDateUtils.formatDate(_selectedDate)}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // ─── Time Slots ───
            Consumer<BookingProvider>(
              builder: (context, bookProv, _) {
                final bookedKeys =
                    bookProv.bookedSlotKeys; // booked slotKeys for this date

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSlots.map((slot) {
                    final isBooked = bookedKeys.contains(slot.slotKey);
                    final isSelected = _selectedSlot?.slotKey == slot.slotKey;

                    return TimeSlotChip(
                      slot: slot.copyWith(isBooked: isBooked),
                      isSelected: isSelected,
                      onTap: isBooked
                          ? null
                          : () {
                              setState(() {
                                _selectedSlot = slot;
                              });
                            },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // ─── Legend ───
            const Row(
              children: [
                _LegendDot(color: AppColors.availableSlot, label: 'Available'),
                SizedBox(width: 16),
                _LegendDot(color: AppColors.bookedSlot, label: 'Booked'),
                SizedBox(width: 16),
                _LegendDot(color: AppColors.selectedSlot, label: 'Selected'),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Notes ───
            CustomTextField(
              controller: _notesController,
              label: 'Notes (optional)',
              prefixIcon: Icons.note_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // ─── Price Info ───
            if (_selectedSlot != null)
              Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedSlot!.startTime} – ${_selectedSlot!.endTime}',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            utils.AppDateUtils.formatDate(_selectedDate),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Text(
                        '₹${_resolvedTurf.pricePerSlot.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ─── Confirm ───
            Consumer<BookingProvider>(
              builder: (context, bookProv, _) {
                return CustomButton(
                  text: AppStrings.confirmBooking,
                  onPressed: _selectedSlot != null ? _confirmBooking : null,
                  isLoading: bookProv.isLoading,
                  icon: Icons.check_circle_outline,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
