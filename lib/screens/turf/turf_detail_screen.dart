import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart';
import '../../models/turf_model.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/common/error_dialog.dart';
import '../booking/booking_screen.dart';

/// Read-only detail screen for a turf. Shows full info and a "Book Now" CTA.
class TurfDetailScreen extends StatelessWidget {
  final String turfId;

  const TurfDetailScreen({super.key, required this.turfId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<TurfProvider>(
      builder: (context, turfProv, _) {
        final turf = turfProv.turfs.where((t) => t.id == turfId).firstOrNull;

        if (turf == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Turf not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ─── Hero image / header ───
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    turf.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 64,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),

              // ─── Body ───
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: turf.location,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.currency_rupee,
                      label: 'Price per Slot',
                      value: '₹${turf.pricePerSlot.toStringAsFixed(0)}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.timer,
                      label: 'Slot Duration',
                      value: '${turf.slotDuration} minutes',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Available Hours',
                      value:
                          '${turf.startHour.toString().padLeft(2, '0')}:00 – ${turf.endHour.toString().padLeft(2, '0')}:00',
                    ),
                    if (turf.description.isNotEmpty) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: 'Description',
                        value: turf.description,
                      ),
                    ],
                    const SizedBox(height: 32),

                    // ─── Book Now ───
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(turf: turf),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Book Now'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
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
    );
  }
}
