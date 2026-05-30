import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/pulp_camera_screen.dart';
import 'services/auth_service.dart';
import 'theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  final loggedIn = await AuthService.isLoggedIn();
  runApp(HarumanisApp(loggedIn: loggedIn));
}

class HarumanisApp extends StatefulWidget {
  final bool loggedIn;
  const HarumanisApp({super.key, required this.loggedIn});

  @override
  State<HarumanisApp> createState() => _HarumanisAppState();
}

class _HarumanisAppState extends State<HarumanisApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen(_handleLink);
  }

  void _handleLink(Uri uri) {
    if (uri.scheme != 'harumanis') return;
    if (uri.host == 'payment') {
      final orderId = int.tryParse(uri.queryParameters['order_id'] ?? '');
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => MyOrdersScreen(paymentOrderId: orderId),
        ),
      );
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Beli Harumanis',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: widget.loggedIn ? const HomeShell() : const LoginScreen(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: [
            const MarketplaceScreen(),
            PulpCameraScreen(isActive: _currentPage == 1),
          ],
        ),
        // Page indicator dots
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _currentPage == 1
                      ? (active
                          ? kAmberMid
                          : Colors.white.withValues(alpha: 0.4))
                      : (active
                          ? kAmberPrimary
                          : kAmberPrimary.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
