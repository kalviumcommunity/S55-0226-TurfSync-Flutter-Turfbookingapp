import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/turf/turf_card.dart';
import '../../widgets/booking/booking_card.dart';
import '../turf/add_turf_screen.dart';
import '../booking/booking_detail_screen.dart';
import '../settings/settings_screen.dart';

/// Admin dashboard: manage turfs and approve/reject bookings.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize real-time listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TurfProvider>().listenToTurfs();
      context.read<BookingProvider>().listenToAllBookings();
      context.read<BookingProvider>().listenToPendingBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildOverview(user?.fullName ?? 'Admin'),
          _buildTurfManagement(),
          _buildBookingApprovals(),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTurfScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addTurf),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Turfs',
          ),
          NavigationDestination(
            icon: Icon(Icons.approval_outlined),
            selectedIcon: Icon(Icons.approval),
            label: 'Approvals',
          ),
        ],
      ),
    );
  }

  /// Overview tab with stats.
  Widget _buildOverview(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.welcome}, $name!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your turfs and bookings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Stats cards
          Consumer2<TurfProvider, BookingProvider>(
            builder: (context, turfProv, bookingProv, _) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Turfs',
                      '${turfProv.turfs.length}',
                      Icons.sports_soccer,
                      AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      '${bookingProv.pendingBookings.length}',
                      Icons.pending_actions,
                      AppColors.pendingColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Bookings',
                      '${bookingProv.bookings.length}',
                      Icons.book_online,
                      AppColors.info,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent pending bookings
          Text(
            'Recent Pending Approvals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Consumer<BookingProvider>(
            builder: (context, bookingProv, _) {
              if (bookingProv.pendingBookings.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No pending approvals')),
                  ),
                );
              }
              return Column(
                children: bookingProv.pendingBookings
                    .take(3)
                    .map((booking) => BookingCard(
                          booking: booking,
                          showActions: true,
                          onApprove: () =>
                              bookingProv.approveBooking(booking.id),
                          onReject: () => bookingProv.rejectBooking(booking.id),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Turf management tab.
  Widget _buildTurfManagement() {
    return Consumer<TurfProvider>(
      builder: (context, turfProv, _) {
        if (turfProv.isLoading) {
          return const LoadingIndicator(message: 'Loading turfs...');
        }
        if (turfProv.turfs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.sports_soccer,
            title: AppStrings.noTurfsFound,
            subtitle: 'Tap + to add your first turf',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: turfProv.turfs.length,
          itemBuilder: (context, index) {
            final turf = turfProv.turfs[index];
            return TurfCard(
              turf: turf,
              showAdminActions: true,
              onTap: () {},
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTurfScreen(existingTurf: turf),
                ),
              ),
              onDelete: () async {
                await turfProv.deleteTurf(turf.id);
              },
            );
          },
        );
      },
    );
  }

  /// Booking approvals tab.
  Widget _buildBookingApprovals() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProv, _) {
        if (bookingProv.isLoading) {
          return const LoadingIndicator(message: 'Loading bookings...');
        }
        if (bookingProv.bookings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.book_online,
            title: AppStrings.noBookings,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: bookingProv.bookings.length,
          itemBuilder: (context, index) {
            final booking = bookingProv.bookings[index];
            return BookingCard(
              booking: booking,
              showActions: true,
              onApprove: () => bookingProv.approveBooking(booking.id),
              onReject: () => bookingProv.rejectBooking(booking.id),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(booking: booking),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
