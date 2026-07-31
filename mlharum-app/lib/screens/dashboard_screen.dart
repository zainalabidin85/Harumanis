import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/tree.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/tree_marker.dart';
import '../widgets/harvest_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FarmDashboard? _dashboard;
  TreeDashboard? _selectedTree;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final farmId = await AuthService.getFarmId();
    if (farmId == null) {
      setState(() { _error = 'No farm found.'; _loading = false; });
      return;
    }
    try {
      final dashboard = await ApiService.getDashboard(farmId);
      setState(() { _dashboard = dashboard; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Failed to load dashboard.'; _loading = false; });
    }
  }

  Set<Marker> _buildMarkers() {
    if (_dashboard == null) return {};
    return _dashboard!.trees
        .where((t) => t.gpsLat != null && t.gpsLng != null)
        .map((tree) => buildTreeMarker(
              tree: tree,
              onTap: () => setState(() => _selectedTree = tree),
            ))
        .toSet();
  }

  LatLng get _farmCenter {
    final trees =
        _dashboard!.trees.where((t) => t.gpsLat != null).toList();
    if (trees.isEmpty) return const LatLng(6.4414, 100.1986);
    final avgLat = trees.map((t) => t.gpsLat!).reduce((a, b) => a + b) /
        trees.length;
    final avgLng = trees.map((t) => t.gpsLng!).reduce((a, b) => a + b) /
        trees.length;
    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dashboard?.farmName ?? 'Farm Dashboard'),
        backgroundColor: const Color(0xFF0369A1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF0369A1)))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 14)))
              : Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.satellite,
                      initialCameraPosition: CameraPosition(
                          target: _farmCenter, zoom: 17),
                      markers: _buildMarkers(),
                      onTap: (_) =>
                          setState(() => _selectedTree = null),
                    ),

                    // ── Summary pill ────────────────────────────────
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: _FarmSummaryBar(dashboard: _dashboard!),
                    ),

                    // ── Tree detail sheet ───────────────────────────
                    if (_selectedTree != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _TreeBottomSheet(
                          tree: _selectedTree!,
                          onClose: () =>
                              setState(() => _selectedTree = null),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _FarmSummaryBar extends StatelessWidget {
  final FarmDashboard dashboard;
  const _FarmSummaryBar({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kElevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Season ${dashboard.currentSeason}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kGreenPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            label: 'Trees',
            value: '${dashboard.totalTrees}',
            icon: Icons.forest_rounded,
            color: kGreenPrimary,
          ),
          Container(width: 1, height: 32, color: kDivider),
          _Stat(
            label: 'Active',
            value: '${dashboard.totalActiveFruits}',
            icon: Icons.eco_rounded,
            color: kGreenMid,
          ),
          Container(width: 1, height: 32, color: kDivider),
          _Stat(
            label: 'Harvested',
            value: '${dashboard.totalHarvestedFruits}',
            icon: Icons.shopping_basket_rounded,
            color: const Color(0xFF0369A1),
          ),
          Container(width: 1, height: 32, color: kDivider),
          _Stat(
            label: 'Aborted',
            value: '${dashboard.totalAbortedFruits}',
            icon: Icons.cancel_outlined,
            color: const Color(0xFFDC2626),
          ),
        ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kText1)),
        Text(label,
            style: GoogleFonts.poppins(
                color: kText2, fontSize: 10)),
      ],
    );
  }
}

class _TreeBottomSheet extends StatelessWidget {
  final TreeDashboard tree;
  final VoidCallback onClose;

  const _TreeBottomSheet(
      {required this.tree, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: kElevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: kDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.forest_rounded,
                    color: kGreenPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tree.treeNumber,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kText1),
                    ),
                    Text(
                      '${tree.fruitCount} active fruits',
                      style: GoogleFonts.poppins(
                          color: kText2, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: kText3),
                onPressed: onClose,
              ),
            ],
          ),
          if (tree.earliestHarvestDate != null) ...[
            const SizedBox(height: 12),
            HarvestBadge(
              harvestDate: tree.earliestHarvestDate!,
              daysToHarvest: tree.daysToHarvest,
            ),
          ],
        ],
      ),
    );
  }
}
