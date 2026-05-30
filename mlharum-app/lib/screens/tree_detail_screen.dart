import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/fruit.dart';
import '../models/tree.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'camera_screen.dart';

class TreeDetailScreen extends StatefulWidget {
  final Tree tree;
  final int farmId;
  const TreeDetailScreen({super.key, required this.tree, required this.farmId});

  @override
  State<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends State<TreeDetailScreen> {
  List<ActiveFruit> _fruits = [];
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
      final fruits = await ApiService.getTreeFruits(widget.tree.id);
      if (mounted) setState(() { _fruits = fruits; _loading = false; });
    } on DioException catch (e) {
      if (mounted) setState(() {
        _error = 'Failed to load fruits (error ${e.response?.statusCode}).';
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  Future<void> _deleteTree() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Tree ${widget.tree.treeNumber}?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete this tree and all its scan history. This cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14, color: kText2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: kText2)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteTree(widget.farmId, widget.tree.id);
      if (mounted) {
        Navigator.pop(context, 'deleted');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(detail ?? 'Failed to delete tree.',
            style: GoogleFonts.poppins()),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showFruitActions(ActiveFruit fruit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FruitActionSheet(
        fruit: fruit,
        onDone: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Tree ${widget.tree.treeNumber}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: kRed),
            tooltip: 'Delete tree',
            onPressed: _deleteTree,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(context,
              FadeSlideRoute(page: CameraScreen(tree: widget.tree)))
              .then((_) => _load());
        },
        backgroundColor: kGreenPrimary,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: Text('+ Add Fruit',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreenPrimary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : _fruits.isEmpty
                  ? _EmptyView(tree: widget.tree)
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: kGreenPrimary,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        children: [
                          _SummaryBar(fruits: _fruits),
                          const SizedBox(height: 16),
                          Text(
                            '${_fruits.length} active fruit${_fruits.length == 1 ? '' : 's'}',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kText3),
                          ),
                          const SizedBox(height: 10),
                          ..._fruits.map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ActiveFruitCard(
                                    fruit: f,
                                    onTap: () => _showFruitActions(f)),
                              )),
                        ],
                      ),
                    ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final List<ActiveFruit> fruits;
  const _SummaryBar({required this.fruits});

  @override
  Widget build(BuildContext context) {
    final stages = {1: 0, 2: 0, 3: 0, 4: 0};
    for (final f in fruits) {
      stages[f.growthStage] = (stages[f.growthStage] ?? 0) + 1;
    }
    final earliest = fruits.isEmpty
        ? null
        : fruits.map((f) => f.harvestDate).reduce(
            (a, b) => a.isBefore(b) ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kGreenPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kGreenPrimary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        const Text('🥭', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${fruits.length} active fruits',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            if (earliest != null)
              Text(
                'Earliest harvest: ${DateFormat('d MMM yyyy').format(earliest)}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
              ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final e in stages.entries.where((e) => e.value > 0))
            Text('S${e.key}: ${e.value}',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85))),
        ]),
      ]),
    );
  }
}

// ── Active fruit card ─────────────────────────────────────────────────────────

class _ActiveFruitCard extends StatelessWidget {
  final ActiveFruit fruit;
  final VoidCallback onTap;
  const _ActiveFruitCard({required this.fruit, required this.onTap});

  Color get _stageColor {
    const colors = {
      1: Color(0xFF16A34A),
      2: Color(0xFF0D9488),
      3: Color(0xFFF59E0B),
      4: Color(0xFFEF4444),
    };
    return colors[fruit.growthStage] ?? kGreenPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final daysText = fruit.daysToHarvest <= 0
        ? 'Ready to harvest'
        : '${fruit.daysToHarvest} days to harvest';
    final harvestStr =
        DateFormat('d MMM yyyy').format(fruit.harvestDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: kCardShadow,
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _stageColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                fruit.label.split('-').last,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _stageColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fruit.label,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kText1)),
              const SizedBox(height: 2),
              Text(
                '${fruit.sizeCm.toStringAsFixed(1)} cm · ${fruit.stageName} · $harvestStr',
                style: GoogleFonts.poppins(fontSize: 12, color: kText2),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _stageColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(daysText,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _stageColor)),
              ),
            ]),
          ),
          const Icon(Icons.more_vert_rounded, color: kText3, size: 20),
        ]),
      ),
    );
  }
}

// ── Action bottom sheet ───────────────────────────────────────────────────────

class _FruitActionSheet extends StatefulWidget {
  final ActiveFruit fruit;
  final VoidCallback onDone;
  const _FruitActionSheet({required this.fruit, required this.onDone});

  @override
  State<_FruitActionSheet> createState() => _FruitActionSheetState();
}

class _FruitActionSheetState extends State<_FruitActionSheet> {
  final _reasonCtrl = TextEditingController();
  bool _showAbortReason = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _harvest() async {
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.harvestFruit(widget.fruit.id);
      if (mounted) { Navigator.pop(context); widget.onDone(); }
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response!.data['detail'] : null;
      setState(() {
        _error = detail ?? 'Failed (error ${e.response?.statusCode}).';
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  Future<void> _abort() async {
    HapticFeedback.mediumImpact();
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.abortFruit(widget.fruit.id,
          reason: _reasonCtrl.text.trim());
      if (mounted) { Navigator.pop(context); widget.onDone(); }
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response!.data['detail'] : null;
      setState(() {
        _error = detail ?? 'Failed (error ${e.response?.statusCode}).';
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fruit = widget.fruit;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(fruit.label,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context)),
        ]),
        Text(
          '${fruit.sizeCm.toStringAsFixed(1)} cm · ${fruit.stageName} · ${fruit.daysToHarvest} days to harvest',
          style: GoogleFonts.poppins(fontSize: 13, color: kText3),
        ),
        const SizedBox(height: 20),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!,
                style: GoogleFonts.poppins(fontSize: 13, color: kRed)),
          ),

        if (_loading)
          const Center(child: CircularProgressIndicator(color: kGreenPrimary))
        else ...[
          // ── Harvest ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _harvest,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Mark as Harvested'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 10),

          // ── Abort ─────────────────────────────────────────────────────────
          if (!_showAbortReason)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showAbortReason = true),
                icon: const Icon(Icons.cancel_outlined, color: kRed),
                label: Text('Mark as Fallen / Aborted',
                    style: GoogleFonts.poppins(color: kRed)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kRed),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            )
          else ...[
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g. Fell from tree, pest damage, thinned',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _abort(),
              autofocus: true,
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showAbortReason = false),
                  child: Text('Cancel',
                      style: GoogleFonts.poppins(color: kText2)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _abort,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Confirm Abort'),
                ),
              ),
            ]),
          ],
        ],
      ]),
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final Tree tree;
  const _EmptyView({required this.tree});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌿', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('No active fruits',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kText1)),
            const SizedBox(height: 6),
            Text('Scan this tree to detect and track mangoes.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
          ]),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded, color: kRed, size: 40),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: kText2, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ]),
        ),
      );
}
