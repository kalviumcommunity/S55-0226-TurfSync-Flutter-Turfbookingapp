import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/turf_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/session/session_card.dart';
import '../../widgets/booking/booking_card.dart';
import '../session/create_session_screen.dart';
import '../booking/booking_screen.dart';
import '../settings/settings_screen.dart';

/// Coach dashboard: create sessions and view bookings.
class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<SessionProvider>().listenToCoachSessions(userId);
      context.read<BookingProvider>().listenToUserBookings(userId);
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
          _buildOverview(user?.fullName ?? 'Coach'),
          _buildSessions(),
          _buildBookings(),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              heroTag: 'coach_fab',
              onPressed: () {
                if (_currentIndex == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreateSessionScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingScreen()),
                  );
                }
              },
              icon: Icon(_currentIndex == 1 ? Icons.add : Icons.book_online),
              label: Text(_currentIndex == 1
                  ? AppStrings.createSession
                  : AppStrings.bookNow),
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
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online),
            label: 'Bookings',
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
            'Manage your practice sessions and bookings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          Consumer2<SessionProvider, BookingProvider>(
            builder: (context, sessionProv, bookingProv, _) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'My Sessions',
                      '${sessionProv.sessions.length}',
                      Icons.fitness_center,
                      AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'My Bookings',
                      '${bookingProv.bookings.length}',
                      Icons.book_online,
                      AppColors.primaryGreen,
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
                    child: Center(child: Text('No turfs available yet')),
                  ),
                );
              }
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: turfProv.turfs.length,
                  itemBuilder: (context, index) {
                    final turf = turfProv.turfs[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sports_soccer,
                                      color: AppColors.primaryGreen, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      turf.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                turf.location,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${turf.startHour}:00 - ${turf.endHour}:00',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
            subtitle: 'Create your first practice session',
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
              isCoachView: true,
              onDelete: () => sessionProv.deleteSession(session.id),
            );
          },
        );
      },
    );
  }

  Widget _buildBookings() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProv, _) {
        if (bookingProv.isLoading) {
          return const LoadingIndicator(message: 'Loading bookings...');
        }
        if (bookingProv.bookings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.book_online,
            title: AppStrings.noBookings,
            subtitle: 'Book a turf to get started',
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
}
