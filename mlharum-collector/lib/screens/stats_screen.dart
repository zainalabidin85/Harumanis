import 'dart:async';
import 'package:flutter/material.dart';
import '../services/upload_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _trainStatus;
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        UploadService.getStats(),
        UploadService.getTrainingStatus(),
      ]);
      setState(() {
        _stats = results[0];
        _trainStatus = results[1];
      });
      _managePollTimer();
    } catch (e) {
      setState(() { _error = 'Could not load stats. Check server connection.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  void _managePollTimer() {
    final state = _trainStatus?['state'] as String? ?? 'idle';
    if (state == 'running') {
      _pollTimer ??= Timer.periodic(const Duration(seconds: 8), (_) => _pollStatus());
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  Future<void> _pollStatus() async {
    try {
      final status = await UploadService.getTrainingStatus();
      if (mounted) {
        setState(() { _trainStatus = status; });
        _managePollTimer();
      }
    } catch (_) {}
  }

  Future<void> _startTraining() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start Training?'),
        content: const Text(
          'This will train a new YOLOv8 model on all collected images using the server GPU.\n\n'
          'Training takes approximately 30–60 minutes. The Ai-Harumanis app will automatically use the new model when done.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text('Start', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await UploadService.startTraining();
      await _pollStatus();
      _managePollTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Training started on server GPU.'), backgroundColor: Colors.green.shade700),
        );
      }
    } on Exception catch (e) {
      final msg = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.contains('400') ? msg : 'Failed to start training. Check connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataset Stats'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final total      = _stats!['total'] as int;
    final labeled    = _stats!['labeled'] as int;
    final totalBoxes = _stats!['total_boxes'] as int;
    final state      = _trainStatus?['state'] as String? ?? 'idle';
    const minBoxes   = 50;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Dataset summary ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(child: _StatCard(value: '$total',      label: 'Images',  color: Colors.green.shade700)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(value: '$labeled',    label: 'Labeled', color: Colors.blue.shade700)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(value: '$totalBoxes', label: 'Boxes',   color: Colors.orange.shade700)),
          ],
        ),
        const SizedBox(height: 20),

        // Class info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Container(width: 14, height: 14,
                decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              const Text('Class 0 — mango', style: TextStyle(fontSize: 14)),
              const Spacer(),
              Text('$totalBoxes boxes', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Capture pre-bagging Harumanis fruits with palm open as scale reference.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),

        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 16),

        // ── Training section ─────────────────────────────────────────────────
        const Text('Model Training', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        if (state == 'running') ...[
          _TrainingProgressCard(status: _trainStatus!),
        ] else if (state == 'done') ...[
          _TrainingResultCard(status: _trainStatus!, success: true),
          const SizedBox(height: 16),
          _buildTrainButton(totalBoxes, minBoxes),
        ] else if (state == 'failed') ...[
          _TrainingResultCard(status: _trainStatus!, success: false),
          const SizedBox(height: 16),
          _buildTrainButton(totalBoxes, minBoxes),
        ] else ...[
          _buildTrainButton(totalBoxes, minBoxes),
        ],
      ],
    );
  }

  Widget _buildTrainButton(int totalBoxes, int minBoxes) {
    final ready = totalBoxes >= minBoxes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: ready ? _startTraining : null,
          icon: const Icon(Icons.model_training, color: Colors.white),
          label: const Text('Train Model on Server GPU', style: TextStyle(fontSize: 15, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            disabledBackgroundColor: Colors.grey.shade400,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (!ready)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Collect at least $minBoxes labeled boxes to enable training. ($totalBoxes/$minBoxes)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    ),
  );
}

class _TrainingProgressCard extends StatelessWidget {
  final Map<String, dynamic> status;
  const _TrainingProgressCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final done  = (status['epochs_done'] as int? ?? 0);
    final total = (status['total_epochs'] as int? ?? 100);
    final pct   = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.blue.shade700)),
            const SizedBox(width: 10),
            Text('Training on server GPU...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.blue.shade100,
              color: Colors.blue.shade600,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Epoch $done / $total', style: TextStyle(color: Colors.blue.shade700, fontSize: 13)),
            Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
          ]),
          const SizedBox(height: 6),
          Text(
            'Images: ${status['total_images']}   Boxes: ${status['total_boxes']}',
            style: TextStyle(color: Colors.blue.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TrainingResultCard extends StatelessWidget {
  final Map<String, dynamic> status;
  final bool success;
  const _TrainingResultCard({required this.status, required this.success});

  String _pct(String key) {
    final v = status[key];
    if (v == null) return '—';
    return '${((v as num) * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final color = success ? Colors.green : Colors.red;
    final hasMetrics = success && status['map50'] != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(success ? Icons.check_circle : Icons.error_outline, color: color.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      success ? 'Training complete — model deployed!' : 'Training failed',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color.shade800),
                    ),
                    if (success)
                      Text('Ai-Harumanis is now using the new model.', style: TextStyle(color: color.shade700, fontSize: 13))
                    else if (status['error'] != null)
                      Text('${status['error']}', style: TextStyle(color: color.shade700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (hasMetrics) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricChip(label: 'mAP50',    value: _pct('map50'),     color: color),
                const SizedBox(width: 8),
                _MetricChip(label: 'mAP50-95', value: _pct('map50_95'),  color: color),
                const SizedBox(width: 8),
                _MetricChip(label: 'Precision', value: _pct('precision'), color: color),
                const SizedBox(width: 8),
                _MetricChip(label: 'Recall',   value: _pct('recall'),    color: color),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final MaterialColor color;
  const _MetricChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color.shade800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color.shade600)),
        ],
      ),
    ),
  );
}
