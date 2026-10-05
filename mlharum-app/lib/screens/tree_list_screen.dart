import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tree.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'tree_detail_screen.dart';
import '../l10n/l10n.dart';

class TreeListScreen extends StatefulWidget {
  const TreeListScreen({super.key});

  @override
  State<TreeListScreen> createState() => _TreeListScreenState();
}

class _TreeListScreenState extends State<TreeListScreen>
    with SingleTickerProviderStateMixin {
  List<Tree> _trees = [];
  bool _loading = true;
  String? _error;
  int? _farmId;

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _loadTrees();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrees() async {
    setState(() { _loading = true; _error = null; });
    final farmId = await AuthService.getFarmId();
    if (farmId == null) {
      setState(() {
        _error = context.l10n.treeListErrorNoFarm;
        _loading = false;
      });
      return;
    }
    _farmId = farmId;
    try {
      final trees = await ApiService.getTrees(farmId);
      if (mounted) {
        setState(() { _trees = trees; _loading = false; });
        _ctrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() { _error = context.l10n.treeListErrorLoad(e.toString()); _loading = false; });
    }
  }

  static const double _kGpsThresholdM = 10.0;

  Future<void> _fetchGps({
    required void Function(Position) onUpdate,
    required void Function(Position?) onDone,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { onDone(null); return; }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) { onDone(null); return; }
    }
    if (permission == LocationPermission.deniedForever) { onDone(null); return; }

    Position? best;
    try {
      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20), onTimeout: (sink) => sink.close());

      await for (final pos in stream) {
        if (best == null || pos.accuracy < best.accuracy) {
          best = pos;
          onUpdate(best);
        }
        if (pos.accuracy <= _kGpsThresholdM) break;
      }
    } catch (_) {}

    onDone(best);
  }

  Future<void> _showAddTreeDialog() async {
    final treeNumCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    // GPS state: 'fetching' | 'ok' | 'error'
    String gpsStatus = 'fetching';
    Position? position;
    bool adding = false;
    bool gpsFetchStarted = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          // Kick off GPS fetch once
          if (!gpsFetchStarted) {
            gpsFetchStarted = true;
            _fetchGps(
              onUpdate: (pos) => setDlg(() => position = pos),
              onDone: (pos) => setDlg(() {
                position = pos;
                gpsStatus = pos != null ? 'ok' : 'error';
              }),
            );
          }

          Widget gpsRow;
          if (gpsStatus == 'fetching') {
            final accuracy = position?.accuracy;
            gpsRow = Row(children: [
              const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: kGreenPrimary)),
              const SizedBox(width: 10),
              Text(
                accuracy != null
                    ? context.l10n.treeListGettingLocationAccuracy(accuracy.toStringAsFixed(0))
                    : context.l10n.treeListGettingLocation,
                style: GoogleFonts.poppins(fontSize: 12, color: kText2),
              ),
            ]);
          } else if (gpsStatus == 'ok' && position != null) {
            gpsRow = Row(children: [
              const Icon(Icons.location_on_rounded, size: 16, color: kGreenPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${position!.latitude.toStringAsFixed(5)}, '
                  '${position!.longitude.toStringAsFixed(5)}  '
                  '(±${position!.accuracy.toStringAsFixed(0)}m)',
                  style: GoogleFonts.poppins(fontSize: 12, color: kGreenPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]);
          } else {
            gpsRow = Row(children: [
              const Icon(Icons.location_off_rounded, size: 16, color: kText3),
              const SizedBox(width: 6),
              Text(context.l10n.treeListLocationUnavailable,
                  style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setDlg(() {
                    gpsStatus = 'fetching';
                    position = null;
                    gpsFetchStarted = false;
                  });
                },
                child: Text(context.l10n.commonRetry,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: kGreenPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ]);
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(context.l10n.treeListAddTree,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: treeNumCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.treeListTreeNumberLabel,
                    hintText: 'e.g. T01',
                    prefixIcon: Icon(Icons.forest_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.treeListNotesLabel,
                    hintText: context.l10n.treeListNotesHint,
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: gpsRow,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: adding ? null : () => Navigator.pop(ctx),
                child: Text(context.l10n.commonCancel, style: GoogleFonts.poppins(color: kText2)),
              ),
              ElevatedButton(
                onPressed: adding
                    ? null
                    : () async {
                        final num = treeNumCtrl.text.trim();
                        if (num.isEmpty) return;
                        setDlg(() => adding = true);
                        try {
                          final tree = await ApiService.createTree(
                            _farmId!,
                            num,
                            notes: notesCtrl.text.trim(),
                            gpsLat: position?.latitude,
                            gpsLng: position?.longitude,
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            setState(() => _trees = [..._trees, tree]);
                            _ctrl.forward(from: 0);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  position != null
                                      ? context.l10n.treeListAddedWithGps(tree.treeNumber)
                                      : context.l10n.treeListAddedNoGps(tree.treeNumber),
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: kGreenPrimary,
                              ),
                            );
                          }
                        } catch (e) {
                          setDlg(() => adding = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.treeListErrorAdd(e.toString()),
                                    style: GoogleFonts.poppins()),
                                backgroundColor: kRed,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: kGreenPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: adding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(context.l10n.commonAdd, style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(context.l10n.homeMyTreesTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: (!_loading && _error == null && _farmId != null)
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAddTreeDialog();
              },
              backgroundColor: kGreenPrimary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(context.l10n.treeListAddTree,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGreenPrimary))
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadTrees)
              : _trees.isEmpty
                  ? _EmptyState(onAddTree: _farmId != null ? _showAddTreeDialog : null)
                  : RefreshIndicator(
                      onRefresh: _loadTrees,
                      color: kGreenPrimary,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        itemCount: _trees.length,
                        itemBuilder: (context, index) {
                          final delay = index * 0.1;
                          final anim = CurvedAnimation(
                            parent: _ctrl,
                            curve: Interval(
                              delay.clamp(0.0, 1.0),
                              (delay + 0.5).clamp(0.0, 1.0),
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.08, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: _TreeCard(
                                  tree: _trees[index],
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    final result = await Navigator.push(
                                      context,
                                      FadeSlideRoute(
                                          page: TreeDetailScreen(
                                              tree: _trees[index],
                                              farmId: _farmId!)),
                                    );
                                    if (result == 'deleted') _loadTrees();
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _TreeCard extends StatelessWidget {
  final Tree tree;
  final VoidCallback onTap;

  const _TreeCard({required this.tree, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            // Green accent bar
            Container(
              width: 5,
              height: 72,
              decoration: const BoxDecoration(
                color: kGreenPrimary,
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            const SizedBox(width: 16),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tree.treeNumber,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: kText1,
                    ),
                  ),
                  if (tree.notes != null && tree.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tree.notes!,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: kText2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kGreenTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: kGreenPrimary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: kRed, size: 32),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: kText2, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAddTree;
  const _EmptyState({this.onAddTree});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(context.l10n.treeListEmptyTitle,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kText1)),
            const SizedBox(height: 6),
            Text(context.l10n.treeListEmptyBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: kText2)),
            if (onAddTree != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAddTree,
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.treeListAddFirstTree),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 46),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
