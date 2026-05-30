import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'tree_list_screen.dart';
import 'dashboard_screen.dart';
import 'pulp_camera_screen.dart';
import 'farm_photos_screen.dart';

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
  }

  Future<void> _loadFarmName() async {
    try {
      final farmId = await AuthService.getFarmId();
      if (farmId == null) return;
      final farm = await ApiService.getFarm(farmId);
      if (mounted) {
        setState(() => _farmName = farm['name'] ?? '');
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
                  tooltip: 'Profile',
                  onPressed: () => Navigator.push(
                      context, FadeSlideRoute(page: const ProfileScreen())),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    tooltip: 'Sign out',
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
                            'Harumanis Farm Manager',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What would you like to do today?',
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
                      label: 'My Trees',
                      subtitle: 'Scan fruit and manage trees',
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
                      label: 'Farm Dashboard',
                      subtitle: 'Satellite map of your farm',
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
                      icon: Icons.colorize_rounded,
                      iconColor: kOrange,
                      iconBg: const Color(0xFFFFEDD5),
                      label: 'Check Pulp Ripeness',
                      subtitle: 'Predict Brix & sweetness from pulp colour',
                      citation: 'Based on Nasir et al. (2021) · UniMAP',
                      onTap: () => Navigator.push(
                        context,
                        FadeSlideRoute(page: const PulpCameraScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    animation: _cardAnims[3],
                    child: _FeatureCard(
                      icon: Icons.photo_library_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFEDE9FE),
                      label: 'Farm Photos',
                      subtitle: 'Add photos to attract buyers',
                      onTap: () => Navigator.push(
                        context,
                        FadeSlideRoute(page: const FarmPhotosScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    animation: _cardAnims[4],
                    child: _FeatureCard(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFFB45309),
                      iconBg: const Color(0xFFFEF3C7),
                      label: 'Incoming Orders',
                      subtitle: 'Manage buyer orders from Harumanis',
                      badge: _pendingOrders > 0 ? '$_pendingOrders new' : null,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          FadeSlideRoute(page: const OrdersScreen()),
                        );
                        _loadPendingOrders();
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ── Partnership footer ────────────────────────────────
                  Center(
                    child: Text(
                      'UniMAP × (Collaborator Here)',
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

// ── Feature card ─────────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final String? citation;
  final String? badge;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.citation,
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
                  if (citation != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      citation!,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: kText3),
                    ),
                  ],
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
