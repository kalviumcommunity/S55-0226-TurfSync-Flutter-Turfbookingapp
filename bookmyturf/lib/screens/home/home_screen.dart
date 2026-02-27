import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/booking_service.dart';
import '../../theme.dart';
import 'dashboard_tab.dart';
import 'turfs_tab.dart';
import 'my_bookings_tab.dart';
import 'schedule_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  static HomeScreenState? instance;

  @override
  void initState() {
    super.initState();
    HomeScreenState.instance = this;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingService>().loadTurfs();
    });
  }

  final _tabs = const [
    DashboardTab(),
    TurfsTab(),
    ScheduleTab(),
    MyBookingsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => setState(() => currentIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryGreen.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon:
                  Icon(Icons.home_rounded, color: AppTheme.primaryGreen),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.stadium_outlined),
              selectedIcon:
                  Icon(Icons.stadium_rounded, color: AppTheme.primaryGreen),
              label: 'Turfs',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded,
                  color: AppTheme.primaryGreen),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outlined),
              selectedIcon:
                  Icon(Icons.bookmark_rounded, color: AppTheme.primaryGreen),
              label: 'My Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
