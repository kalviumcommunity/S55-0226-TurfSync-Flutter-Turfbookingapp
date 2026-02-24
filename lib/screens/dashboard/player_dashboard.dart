import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/booking/booking_card.dart';
import '../../widgets/session/session_card.dart';
import '../booking/booking_screen.dart';
import '../settings/settings_screen.dart';

/// Player dashboard: view bookings and join practice sessions.
class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<BookingProvider>().listenToUserBookings(userId);
      context.read<SessionProvider>().listenToSessions();
      context.read<TurfProvider>().listenToTurfs();
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
          _buildOverview(user?.fullName ?? 'Player'),
          _buildMyBookings(),
          _buildSessions(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'player_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingScreen()),
        ),
        icon: const Icon(Icons.book_online),
        label: const Text(AppStrings.bookNow),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online),
            label: 'My Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Sessions',
          ),
        ],
      ),
    );
  }

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
            'Find and book turfs, join practice sessions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Quick stats
          Consumer2<BookingProvider, SessionProvider>(
            builder: (context, bookingProv, sessionProv, _) {
              final userId = context.read<AuthProvider>().userId;
              final joinedSessions = sessionProv.sessions
                  .where((s) => s.hasPlayerJoined(userId))
                  .length;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'My Bookings',
                      '${bookingProv.bookings.length}',
                      Icons.book_online,
                      AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Joined Sessions',
                      '$joinedSessions',
                      Icons.fitness_center,
                      AppColors.accentOrange,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Available turfs
          Text(
            'Available Turfs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Consumer<TurfProvider>(
            builder: (context, turfProv, _) {
              if (turfProv.turfs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No turfs available')),
                  ),
                );
              }
              return Column(
                children: turfProv.turfs
                    .take(3)
                    .map((turf) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.sports_soccer,
                                  color: AppColors.primaryGreen),
                            ),
                            title: Text(turf.name),
                            subtitle: Text(turf.location),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.read<TurfProvider>().selectTurf(turf);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => BookingScreen(turf: turf)),
                              );
                            },
                          ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookings() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProv, _) {
        if (bookingProv.isLoading) {
          return const LoadingIndicator(message: 'Loading bookings...');
        }
        if (bookingProv.bookings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.book_online,
            title: AppStrings.noBookings,
            subtitle: 'Book a turf to see your bookings here',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: bookingProv.bookings.length,
          itemBuilder: (context, index) {
            final booking = bookingProv.bookings[index];
            return BookingCard(
              booking: booking,
              onCancel: () => bookingProv.cancelBooking(booking.id),
            );
          },
        );
      },
    );
  }

  Widget _buildSessions() {
    return Consumer<SessionProvider>(
      builder: (context, sessionProv, _) {
        if (sessionProv.isLoading) {
          return const LoadingIndicator(message: 'Loading sessions...');
        }
        if (sessionProv.sessions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.fitness_center,
            title: AppStrings.noSessions,
            subtitle: 'No practice sessions available yet',
          );
        }
        final userId = context.read<AuthProvider>().userId;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sessionProv.sessions.length,
          itemBuilder: (context, index) {
            final session = sessionProv.sessions[index];
            return SessionCard(
              session: session,
              currentUserId: userId,
              onJoin: () => sessionProv.joinSession(session.id, userId),
              onLeave: () => sessionProv.leaveSession(session.id, userId),
            );
          },
        );
      },
    );
  }
}
