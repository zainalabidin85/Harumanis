import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/farm.dart';
import '../models/farm_image.dart';
import '../models/testimonial.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import '../widgets/stage_badge.dart';
import 'order_screen.dart';

class FarmDetailScreen extends StatefulWidget {
  final int farmId;
  const FarmDetailScreen({super.key, required this.farmId});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  FarmDetail? _farm;
  List<Testimonial> _reviews = [];
  bool _loading = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getFarmDetail(widget.farmId),
        ApiService.getFarmReviews(widget.farmId),
      ]);
      _farm = results[0] as FarmDetail;
      _reviews = results[1] as List<Testimonial>;
    } catch (e) {
      _error = 'Failed to load farm details.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _placeOrder() {
    if (_farm == null) return;
    HapticFeedback.mediumImpact();
    Navigator.push(context, FadeSlideRoute(page: OrderScreen(farm: _farm!)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_error!, style: GoogleFonts.poppins(color: kText2)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ]),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 160,
                      pinned: true,
                      backgroundColor: kAmberPrimary,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                        title: Text(_farm!.farmName,
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF78350F), Color(0xFFC2680A)],
                            ),
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 32),
                                  if (_farm!.location != null)
                                    Text(_farm!.location!,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── Photo carousel ─────────────────────────────────
                          if (_farm!.images.isNotEmpty) ...[
                            _ImageCarousel(
                              images: _farm!.images,
                              currentPage: _currentPage,
                              onPageChanged: (p) => setState(() => _currentPage = p),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // ── Farmer info ────────────────────────────────────
                          _Section(
                            child: Row(children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                    color: kAmberLight, borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.person_rounded, color: kAmberPrimary, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(_farm!.farmerName,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w600, color: kText1)),
                                  if (_farm!.farmerVerified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF0EA5E9)),
                                  ],
                                ]),
                                Text(
                                  _farm!.farmerVerified ? 'Verified Farm Owner' : 'Farm Owner',
                                  style: GoogleFonts.poppins(fontSize: 12,
                                      color: _farm!.farmerVerified ? const Color(0xFF0EA5E9) : kText2),
                                ),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: 14),

                          // ── Fruit summary ──────────────────────────────────
                          _Section(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Available Fruit',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, fontWeight: FontWeight.w600, color: kText1)),
                              const SizedBox(height: 16),
                              Row(children: [
                                _StatBox(value: '${_farm!.totalActiveFruits}', label: 'Total'),
                                const SizedBox(width: 10),
                                _StatBox(value: '${_farm!.stage3Count + _farm!.stage4Count}',
                                    label: 'Near harvest', highlight: true),
                                const SizedBox(width: 10),
                                if (_farm!.earliestHarvestDate != null)
                                  _StatBox(
                                      value: DateFormat('d MMM').format(_farm!.earliestHarvestDate!),
                                      label: 'First harvest'),
                              ]),
                              const SizedBox(height: 16),
                              Row(children: [
                                Expanded(child: _StageChip(stage: 1, count: _farm!.stage1Count)),
                                const SizedBox(width: 8),
                                Expanded(child: _StageChip(stage: 2, count: _farm!.stage2Count)),
                                const SizedBox(width: 8),
                                Expanded(child: _StageChip(stage: 3, count: _farm!.stage3Count)),
                                const SizedBox(width: 8),
                                Expanded(child: _StageChip(stage: 4, count: _farm!.stage4Count)),
                              ]),
                            ]),
                          ),
                          const SizedBox(height: 14),

                          // ── Trees ──────────────────────────────────────────
                          _Section(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Tree Breakdown',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, fontWeight: FontWeight.w600, color: kText1)),
                              const SizedBox(height: 12),
                              ...(_farm!.trees.where((t) => t.fruitCount > 0).map((tree) =>
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                            color: kAmberLight,
                                            borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.park_rounded,
                                            color: kAmberPrimary, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text('Tree ${tree.treeNumber}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 13, fontWeight: FontWeight.w500)),
                                          if (tree.earliestHarvestDate != null)
                                            Text('Est. harvest: ${DateFormat('d MMM yyyy').format(tree.earliestHarvestDate!)}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11, color: kText2)),
                                        ]),
                                      ),
                                      Text('${tree.fruitCount} fruits',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12, color: kAmberPrimary,
                                              fontWeight: FontWeight.w600)),
                                    ]),
                                  ))),
                              if (_farm!.trees.every((t) => t.fruitCount == 0))
                                Text('No fruits detected yet.',
                                    style: GoogleFonts.poppins(color: kText2, fontSize: 13)),
                            ]),
                          ),
                          const SizedBox(height: 14),

                          // ── Reviews ────────────────────────────────────────
                          _ReviewsSection(reviews: _reviews, farmId: widget.farmId),
                        ]),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _farm == null || _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Place an Order'),
                  onPressed: _placeOrder,
                ),
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: kCardShadow),
      child: child,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;
  const _StatBox({required this.value, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? kAmberLight : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: highlight ? kAmberPrimary : kText1)),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: highlight ? kAmberPrimary : kText2)),
      ]),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<FarmImage> images;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  const _ImageCarousel(
      {required this.images, required this.currentPage, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) {
                final img = images[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: img.thumbUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFF3F4F6),
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: kText3, size: 48),
                        ),
                      ),
                    ),
                    if (img.caption != null && img.caption!.isNotEmpty)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent,
                                Colors.black.withValues(alpha: 0.55)],
                            ),
                          ),
                          child: Text(img.caption!,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == currentPage ? kAmberPrimary : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StageChip extends StatelessWidget {
  final int stage;
  final int count;
  const _StageChip({required this.stage, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      FittedBox(fit: BoxFit.scaleDown, child: StageBadge(stage: stage)),
      const SizedBox(height: 4),
      Text('$count', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: kText1)),
    ]);
  }
}

// ── Reviews section ───────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  final List<Testimonial> reviews;
  final int farmId;
  const _ReviewsSection({required this.reviews, required this.farmId});

  @override
  Widget build(BuildContext context) {
    final avgRating = reviews.isEmpty
        ? null
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: kCardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Reviews',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: kText1)),
          const Spacer(),
          if (avgRating != null) ...[
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              '${avgRating.toStringAsFixed(1)} (${reviews.length})',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: kText1),
            ),
          ] else
            Text('${reviews.length} reviews',
                style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
        ]),
        const SizedBox(height: 14),
        if (reviews.isEmpty)
          Text('No reviews yet. Be the first to share your experience!',
              style: GoogleFonts.poppins(fontSize: 13, color: kText2))
        else
          ...reviews.map((r) => _ReviewCard(review: r)),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Testimonial review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                color: kAmberLight, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                review.buyerName.isNotEmpty ? review.buyerName[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700, color: kAmberPrimary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.buyerName,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kText1)),
              Text(DateFormat('d MMM yyyy').format(review.createdAt),
                  style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
            ]),
          ),
          Row(
            children: List.generate(5, (i) => Icon(
              i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 15,
              color: i < review.rating ? const Color(0xFFF59E0B) : kText3,
            )),
          ),
        ]),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(review.comment!,
              style: GoogleFonts.poppins(fontSize: 13, color: kText2, height: 1.4)),
        ],
        const SizedBox(height: 4),
        const Divider(height: 1),
      ]),
    );
  }
}
