import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l10n/l10n.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/locale_service.dart';
import 'services/push_notification_service.dart';
import 'services/version_service.dart';
import 'theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  // Push notifications are Android/iOS-first; there's no web Firebase config,
  // so skip init on web rather than crashing at startup.
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.init(navigatorKey);
  }
  await LocaleController.instance.load();
  final loggedIn = await AuthService.isLoggedIn();
  if (loggedIn) unawaited(LocaleController.instance.syncToAccount());
  runApp(AiHarumApp(loggedIn: loggedIn));
}

class AiHarumApp extends StatelessWidget {
  final bool loggedIn;
  const AiHarumApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) => MaterialApp(
        title: 'Ai-Harumanis',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        navigatorKey: navigatorKey,
        locale: LocaleController.instance.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VersionGate(
          child: loggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      ),
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
    final l10n = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: !force,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            force ? l10n.updateRequiredTitle : l10n.updateAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            force
                ? l10n.updateRequiredBody(latest)
                : l10n.updateAvailableBody(latest),
          ),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.updateLater),
              ),
            TextButton(
              onPressed: force ? SystemNavigator.pop : () => Navigator.pop(context),
              child: Text(force ? l10n.updateExit : l10n.updateOk),
            ),
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(VersionService.apkUrl),
                mode: LaunchMode.externalApplication,
              ),
              style: TextButton.styleFrom(foregroundColor: kGreenPrimary),
              child: Text(l10n.updateDownload),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
