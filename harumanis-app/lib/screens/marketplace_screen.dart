import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/farm.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'farm_detail_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<FarmSummary> _farms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _farms = await ApiService.getMarketplace();
    } catch (e) {
      _error = 'Failed to load farms. Pull to refresh.';
    } finally {
      if (mounted) setState(() => _loading = false);
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
            // ── Hero ────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              backgroundColor: kAmberDark,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                  tooltip: 'My Orders',
                  onPressed: () => Navigator.push(
                      context, FadeSlideRoute(page: const MyOrdersScreen())),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
                  tooltip: 'Profile',
                  onPressed: () => Navigator.push(
                      context, FadeSlideRoute(page: const ProfileScreen())),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 0, 14),
                title: Text('Beli Harumanis',
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // gradient background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF451A03), Color(0xFF92400E)],
                        ),
                      ),
                    ),
                    // subtle pattern overlay
                    Opacity(
                      opacity: 0.06,
                      child: Image.network(
                        'https://www.transparenttextures.com/patterns/leaf.png',
                        repeat: ImageRepeat.repeat,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    // content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 80, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(children: [
                              const Text('🥭', style: TextStyle(fontSize: 36)),
                              const SizedBox(width: 12),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Harumanis Perlis',
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Malaysia\'s finest mango',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.7))),
                              ]),
                            ]),
                            const SizedBox(height: 16),
                            // value props row
                            Row(children: [
                              _HeroPill(icon: Icons.agriculture_rounded, label: 'Direct from farm'),
                              const SizedBox(width: 8),
                              _HeroPill(icon: Icons.science_rounded, label: 'AI-tracked harvest'),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.cloud_off_rounded, size: 48, color: kText3),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: kText2)),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ]),
                  ),
                ),
              )
            else if (_farms.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            '${_farms.length} farm${_farms.length > 1 ? 's' : ''} available',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: kText2, fontWeight: FontWeight.w500),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FarmCard(farm: _farms[i - 1]),
                      );
                    },
                    childCount: _farms.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Hero pill ─────────────────────────────────────────────────────────────────

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── Farm card ─────────────────────────────────────────────────────────────────

class _FarmCard extends StatelessWidget {
  final FarmSummary farm;
  const _FarmCard({required this.farm});

  @override
  Widget build(BuildContext context) {
    final harvestDate = farm.earliestHarvestDate;
    final daysLeft = harvestDate?.difference(DateTime.now()).inDays;
    final hasPhoto = farm.thumbnailUrl != null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, FadeSlideRoute(page: FarmDetailScreen(farmId: farm.farmId)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: kCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo / no-photo header ──────────────────────────────
            if (hasPhoto)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: farm.thumbnailUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 160,
                      color: kAmberLight,
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: kAmberPrimary)),
                    ),
                    errorWidget: (_, __, ___) => _NoPhotoHeader(farm: farm),
                  ),
                  // gradient scrim for readability
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                        ),
                      ),
                    ),
                  ),
                  // price badge over photo
                  if (farm.pricePerKg != null)
                    Positioned(
                      top: 12, right: 12,
                      child: _PriceBadge(price: farm.pricePerKg!),
                    ),
                  // harvest urgency over photo
                  if (daysLeft != null)
                    Positioned(
                      bottom: 10, left: 12,
                      child: _HarvestBadge(daysLeft: daysLeft),
                    ),
                ],
              )
            else
              _NoPhotoHeader(farm: farm),

            // ── Card body ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(farm.farmName,
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w700, color: kText1)),
                        if (farm.location != null) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: kText3),
                            const SizedBox(width: 3),
                            Text(farm.location!,
                                style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
                          ]),
                        ],
                      ]),
                    ),
                    // price badge (when no photo)
                    if (!hasPhoto && farm.pricePerKg != null)
                      _PriceBadge(price: farm.pricePerKg!),
                  ]),
                  const SizedBox(height: 12),

                  // stats row
                  Row(children: [
                    _StatChip(
                      icon: Icons.eco_rounded,
                      label: '${farm.totalActiveFruits} mangoes',
                      color: kAmberPrimary,
                    ),
                    const SizedBox(width: 8),
                    if (!hasPhoto && daysLeft != null)
                      _HarvestBadge(daysLeft: daysLeft),
                  ]),
                  const SizedBox(height: 12),

                  // stage bar
                  _StageBar(farm: farm),
                  const SizedBox(height: 10),

                  // farmer + verified + chevron
                  Row(children: [
                    const Icon(Icons.person_outline, size: 14, color: kText3),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Row(children: [
                        Text(farm.farmerName,
                            style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
                        if (farm.farmerVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0EA5E9)),
                        ],
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: kText3, size: 20),
                  ]),
                  if (farm.reviewCount > 0) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        '${farm.avgRating?.toStringAsFixed(1) ?? '-'}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w600, color: kText1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${farm.reviewCount} review${farm.reviewCount > 1 ? 's' : ''})',
                        style: GoogleFonts.poppins(fontSize: 11, color: kText2),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No-photo header (amber gradient with farm initial) ────────────────────────

class _NoPhotoHeader extends StatelessWidget {
  final FarmSummary farm;
  const _NoPhotoHeader({required this.farm});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF92400E), Color(0xFFD97706)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              farm.farmName.isNotEmpty ? farm.farmName[0].toUpperCase() : '🥭',
              style: GoogleFonts.poppins(
                  fontSize: 48, fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          if (farm.pricePerKg != null)
            Positioned(top: 10, right: 10, child: _PriceBadge(price: farm.pricePerKg!)),
        ],
      ),
    );
  }
}

// ── Price badge ───────────────────────────────────────────────────────────────

class _PriceBadge extends StatelessWidget {
  final double price;
  const _PriceBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kAmberDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)],
      ),
      child: Text(
        'RM ${price.toStringAsFixed(0)}/kg',
        style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

// ── Harvest badge ─────────────────────────────────────────────────────────────

class _HarvestBadge extends StatelessWidget {
  final int daysLeft;
  const _HarvestBadge({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final isReady = daysLeft <= 0;
    final isClose = daysLeft <= 14;
    final color = isReady ? kGreen : (isClose ? kAmberMid : kText2);
    final bg = isReady
        ? const Color(0xFFDCFCE7)
        : (isClose ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6));
    final label = isReady ? 'Ready to harvest!' : 'Harvest in ${daysLeft}d';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.calendar_today_rounded, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ── Stage bar ─────────────────────────────────────────────────────────────────

class _StageBar extends StatelessWidget {
  final FarmSummary farm;
  const _StageBar({required this.farm});

  @override
  Widget build(BuildContext context) {
    final total = farm.totalActiveFruits;
    if (total == 0) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Growth stages',
          style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 8,
          child: Row(children: [
            _Bar(count: farm.stage1Count, total: total, color: const Color(0xFFD1D5DB)),
            _Bar(count: farm.stage2Count, total: total, color: const Color(0xFF38BDF8)),
            _Bar(count: farm.stage3Count, total: total, color: kAmberMid),
            _Bar(count: farm.stage4Count, total: total, color: kGreen),
          ]),
        ),
      ),
      const SizedBox(height: 6),
      Wrap(spacing: 10, runSpacing: 4, children: [
        if (farm.stage1Count > 0)
          _LegendDot(color: const Color(0xFFD1D5DB), label: 'Early ${farm.stage1Count}'),
        if (farm.stage2Count > 0)
          _LegendDot(color: const Color(0xFF38BDF8), label: 'Mid ${farm.stage2Count}'),
        if (farm.stage3Count > 0)
          _LegendDot(color: kAmberMid, label: 'Late ${farm.stage3Count}'),
        if (farm.stage4Count > 0)
          _LegendDot(color: kGreen, label: 'Pre-harvest ${farm.stage4Count}'),
      ]),
    ]);
  }
}

class _Bar extends StatelessWidget {
  final int count;
  final int total;
  final Color color;
  const _Bar({required this.count, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Expanded(flex: count, child: Container(color: color));
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: kText2)),
    ]);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        children: [
          // mango illustration
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: kAmberLight,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: kAmberPrimary.withValues(alpha: 0.15), blurRadius: 24)],
            ),
            child: const Center(child: Text('🥭', style: TextStyle(fontSize: 52))),
          ),
          const SizedBox(height: 24),
          Text('Coming Soon',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w700, color: kText1)),
          const SizedBox(height: 8),
          Text(
            'Harumanis farms from Perlis & Kedah\nwill appear here once listed.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: kText2, height: 1.5),
          ),
          const SizedBox(height: 32),
          // what is Harumanis
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: kCardShadow,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What is Harumanis?',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700, color: kText1)),
              const SizedBox(height: 12),
              _FactRow(icon: '🏆',
                  text: 'Malaysia\'s most prized mango variety — grown only in Perlis & Kedah'),
              _FactRow(icon: '🍯',
                  text: 'Exceptionally sweet, fiberless flesh with a distinct honey aroma'),
              _FactRow(icon: '📅',
                  text: 'Short season — harvested once a year, making it rare and highly sought after'),
              _FactRow(icon: '🤝',
                  text: 'Order directly from the farm — fresh, traceable, no middlemen'),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAmberLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.notifications_outlined, color: kAmberPrimary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pull down to refresh once farms are listed.',
                  style: GoogleFonts.poppins(fontSize: 13, color: kAmberPrimary),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String icon;
  final String text;
  const _FactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: GoogleFonts.poppins(fontSize: 13, color: kText2, height: 1.4)),
        ),
      ]),
    );
  }
}
