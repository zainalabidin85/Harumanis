import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/farm_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/pulp_camera_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/version_service.dart';
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
    NotificationService.init();
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
    } else if (uri.host == 'farm') {
      final farmId = int.tryParse(uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '');
      if (farmId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => FarmDetailScreen(farmId: farmId),
          ),
        );
      }
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
      home: VersionGate(
        child: widget.loggedIn ? const HomeShell() : const LoginScreen(),
      ),
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

class VersionGate extends StatefulWidget {
  final Widget child;
  const VersionGate({super.key, required this.child});

  @override
  State<VersionGate> createState() => _VersionGateState();
}

class _VersionGateState extends State<VersionGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
  }

  Future<void> _checkVersion() async {
    final status = await VersionService.check();
    if (!mounted) return;
    if (status.result == VersionCheckResult.forceUpdate) {
      _showDialog(force: true, latest: status.latestVersion);
    } else if (status.result == VersionCheckResult.softUpdate) {
      _showDialog(force: false, latest: status.latestVersion);
    }
  }

  void _showDialog({required bool force, required String latest}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: !force,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            force ? 'Update Required' : 'Update Available',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            force
                ? 'Beli Harumanis v$latest is required. Download the latest APK to continue.'
                : 'Beli Harumanis v$latest is available with new features and fixes.',
          ),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
            TextButton(
              onPressed: force ? SystemNavigator.pop : () => Navigator.pop(context),
              child: Text(force ? 'Exit' : 'OK'),
            ),
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(VersionService.apkUrl),
                mode: LaunchMode.externalApplication,
              ),
              style: TextButton.styleFrom(foregroundColor: kAmberPrimary),
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
