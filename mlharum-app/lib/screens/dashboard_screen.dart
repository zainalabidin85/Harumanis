import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/tree.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
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
    } catch (e) {
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
    final trees = _dashboard!.trees.where((t) => t.gpsLat != null).toList();
    if (trees.isEmpty) return const LatLng(6.4414, 100.1986); // Perlis default
    final avgLat = trees.map((t) => t.gpsLat!).reduce((a, b) => a + b) / trees.length;
    final avgLng = trees.map((t) => t.gpsLng!).reduce((a, b) => a + b) / trees.length;
    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dashboard?.farmName ?? 'Farm Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.satellite,
                      initialCameraPosition: CameraPosition(target: _farmCenter, zoom: 17),
                      markers: _buildMarkers(),
                      onTap: (_) => setState(() => _selectedTree = null),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: _FarmSummaryBar(dashboard: _dashboard!),
                    ),
                    if (_selectedTree != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _TreeBottomSheet(
                          tree: _selectedTree!,
                          onClose: () => setState(() => _selectedTree = null),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Trees', value: '${dashboard.totalTrees}', icon: Icons.forest),
          _Stat(label: 'Active Fruits', value: '${dashboard.totalActiveFruits}', icon: Icons.eco),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _TreeBottomSheet extends StatelessWidget {
  final TreeDashboard tree;
  final VoidCallback onClose;
  const _TreeBottomSheet({required this.tree, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tree.treeNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
          Text('${tree.fruitCount} active fruits', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          if (tree.earliestHarvestDate != null)
            HarvestBadge(
              harvestDate: tree.earliestHarvestDate!,
              daysToHarvest: tree.daysToHarvest,
            ),
        ],
      ),
    );
  }
}
