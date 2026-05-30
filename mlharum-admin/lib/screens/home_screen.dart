import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';
import 'farms_screen.dart';
import 'orders_screen.dart';
import 'payouts_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _screens = [
    DashboardScreen(),
    UsersScreen(),
    FarmsScreen(),
    OrdersScreen(),
    PayoutsScreen(),
  ];

  static const _labels = ['Dashboard', 'Users', 'Farms', 'Orders', 'Payouts'];
  static const _icons  = [
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.agriculture_outlined,
    Icons.receipt_long_outlined,
    Icons.account_balance_wallet_outlined,
  ];
  static const _activeIcons = [
    Icons.dashboard_rounded,
    Icons.people_rounded,
    Icons.agriculture_rounded,
    Icons.receipt_long_rounded,
    Icons.account_balance_wallet_rounded,
  ];

  void _signOut() async {
    await AuthService.deleteToken();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_labels[_tab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: kIndigo100,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(5, (i) => NavigationDestination(
          icon: Icon(_icons[i], color: kText3),
          selectedIcon: Icon(_activeIcons[i], color: kIndigo700),
          label: _labels[i],
        )),
      ),
    );
  }
}
