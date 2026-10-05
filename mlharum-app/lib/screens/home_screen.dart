import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'tree_list_screen.dart';
import 'dashboard_screen.dart';
import 'pulp_camera_screen.dart';
import 'farm_photos_screen.dart';
import 'qr_screen.dart';
import 'doa_report_screen.dart';
import 'announcements_screen.dart';
import '../l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _cardAnims;
  int _pendingOrders = 0;
  String _farmName = '';
  int? _farmId;
  int _readyInDays = 4;
  bool _showDoaCard = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _cardAnims = List.generate(5, (i) {
      final start = 0.1 + i * 0.12;
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, (start + 0.5).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      );
    });
    _ctrl.forward();
    _loadPendingOrders();
    _loadFarmName();
    _loadRole();
    PushNotificationService.registerToken();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _showDoaCard = role == 'doa' || role == 'admin');
  }

  Future<void> _loadFarmName() async {
    try {
      final farmId = await AuthService.getFarmId();
      if (farmId == null) return;
      final farm = await ApiService.getFarm(farmId);
      if (mounted) {
        setState(() {
          _farmName = farm['name'] ?? '';
          _farmId = farmId;
          _readyInDays = (farm['ready_in_days'] as int?) ?? 4;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPendingOrders() async {
    try {
      final farmId = await AuthService.getFarmId();
      if (farmId == null) return;
      final orders = await ApiService.getFarmOrders(farmId);
      if (mounted) {
        setState(() => _pendingOrders =
            orders.where((o) => o.status == 'pending').length);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openBuyerTools() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _BuyerToolsSheet(
        pendingOrders: _pendingOrders,
        farmId: _farmId,
        farmName: _farmName,
        readyInDays: _readyInDays,
        onOrdersViewed: _loadPendingOrders,
      ),
    );
  }

  Future<void> _logout() async {
    HapticFeedback.mediumImpact();
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
          context, FadeSlideRoute(page: const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Collapsing hero header ───────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              backgroundColor: kGreenPrimary,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
                  tooltip: context.l10n.homeProfileTooltip,
                  onPressed: () => Navigator.push(
                      context, FadeSlideRoute(page: const ProfileScreen())),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    tooltip: context.l10n.homeSignOutTooltip,
                    onPressed: _logout,
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 14),
                title: Text(
                  'Ai-Harumanis',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A2E17), Color(0xFF1E7040)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 80, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.white.withValues(alpha: 0.15),
                                ),
                                child: const Center(
                                  child: Text('🥭',
                                      style: TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _farmName.isNotEmpty ? _farmName : 'Ai-Harumanis',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.loginTagline,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.homePrompt,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Feature cards ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AnimatedCard(
                    animation: _cardAnims[0],
                    child: _FeatureCard(
                      icon: Icons.forest_rounded,
                      iconColor: kGreenPrimary,
                      iconBg: kGreenLight,
                      label: context.l10n.homeMyTreesTitle,
                      subtitle: context.l10n.homeMyTreesSubtitle,
                      onTap: () => Navigator.push(
                        context,
                        FadeSlideRoute(page: const TreeListScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    animation: _cardAnims[1],
                    child: _FeatureCard(
                      icon: Icons.satellite_alt_rounded,
                      iconColor: const Color(0xFF0369A1),
                      iconBg: const Color(0xFFE0F2FE),
                      label: context.l10n.homeDashboardTitle,
                      subtitle: context.l10n.homeDashboardSubtitle,
                      onTap: () => Navigator.push(
                        context,
                        FadeSlideRoute(page: const DashboardScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    animation: _cardAnims[2],
                    child: _FeatureCard(
                      icon: Icons.storefront_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFEDE9FE),
                      label: 'Jual Harumanis',
                      subtitle: context.l10n.homeSellSubtitle,
                      badge: _pendingOrders > 0 ? context.l10n.homeNewBadge(_pendingOrders) : null,
                      onTap: _openBuyerTools,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    animation: _cardAnims[3],
                    child: _FeatureCard(
                      icon: Icons.campaign_rounded,
                      iconColor: const Color(0xFF0891B2),
                      iconBg: const Color(0xFFCFFAFE),
                      label: context.l10n.homeAnnouncementsTitle,
                      subtitle: context.l10n.homeAnnouncementsSubtitle,
                      onTap: () => Navigator.push(
                        context,
                        FadeSlideRoute(page: const AnnouncementsScreen()),
                      ),
                    ),
                  ),
                  if (_showDoaCard) ...[
                    const SizedBox(height: 16),
                    _AnimatedCard(
                      animation: _cardAnims[4],
                      child: _FeatureCard(
                        icon: Icons.assessment_rounded,
                        iconColor: const Color(0xFF166534),
                        iconBg: kGreenLight,
                        label: context.l10n.homeDoaMonitorTitle,
                        subtitle: context.l10n.homeDoaMonitorSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          FadeSlideRoute(page: const DoaReportScreen()),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // ── Partnership footer ────────────────────────────────
                  Center(
                    child: Text(
                      'UniMAP × DOA Perlis',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: kText3),
                    ),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated wrapper ─────────────────────────────────────────────────────────
class _AnimatedCard extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedCard({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }
}

// ── Buyer Tools sheet ────────────────────────────────────────────────────────
class _BuyerToolsSheet extends StatelessWidget {
  final int pendingOrders;
  final int? farmId;
  final String farmName;
  final int readyInDays;
  final VoidCallback onOrdersViewed;

  const _BuyerToolsSheet({
    required this.pendingOrders,
    required this.farmId,
    required this.farmName,
    required this.readyInDays,
    required this.onOrdersViewed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jual Harumanis',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kText1,
              ),
            ),
            const SizedBox(height: 16),
            _BuyerToolRow(
              icon: Icons.photo_library_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FE),
              label: context.l10n.homeFarmPhotosTitle,
              subtitle: context.l10n.homeFarmPhotosSubtitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  FadeSlideRoute(page: const FarmPhotosScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _BuyerToolRow(
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFFB45309),
              iconBg: const Color(0xFFFEF3C7),
              label: context.l10n.homeIncomingOrdersTitle,
              subtitle: context.l10n.homeIncomingOrdersSubtitle,
              badge: pendingOrders > 0 ? context.l10n.homeNewBadge(pendingOrders) : null,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  FadeSlideRoute(page: const OrdersScreen()),
                );
                onOrdersViewed();
              },
            ),
            const SizedBox(height: 10),
            _BuyerToolRow(
              icon: Icons.colorize_rounded,
              iconColor: kOrange,
              iconBg: const Color(0xFFFFEDD5),
              label: context.l10n.homePulpTitle,
              subtitle: context.l10n.homePulpSubtitle,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  FadeSlideRoute(page: const PulpCameraScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _BuyerToolRow(
              icon: Icons.qr_code_rounded,
              iconColor: const Color(0xFF0369A1),
              iconBg: const Color(0xFFE0F2FE),
              label: context.l10n.homeReminderQrTitle,
              subtitle: context.l10n.homeReminderQrSubtitle,
              onTap: () {
                if (farmId == null) return;
                Navigator.pop(context);
                Navigator.push(
                  context,
                  FadeSlideRoute(
                    page: QrScreen(
                      farmId: farmId!,
                      farmName: farmName.isNotEmpty ? farmName : context.l10n.commonMyFarm,
                      initialReadyInDays: readyInDays,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BuyerToolRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _BuyerToolRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kText1,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kAmber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(badge!,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: kText2),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: kText3, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Feature card ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kText1,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kAmber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(badge!,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: kText2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: kText3, size: 22),
          ],
        ),
      ),
    );
  }
}
