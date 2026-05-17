import 'package:flutter/material.dart';
import '../models/tree.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'camera_screen.dart';

class TreeListScreen extends StatefulWidget {
  const TreeListScreen({super.key});

  @override
  State<TreeListScreen> createState() => _TreeListScreenState();
}

class _TreeListScreenState extends State<TreeListScreen> {
  List<Tree> _trees = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrees();
  }

  Future<void> _loadTrees() async {
    final farmId = await AuthService.getFarmId();
    if (farmId == null) {
      setState(() { _error = 'No farm found. Please set up your farm first.'; _loading = false; });
      return;
    }
    try {
      final trees = await ApiService.getTrees(farmId);
      setState(() { _trees = trees; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load trees.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trees'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _trees.isEmpty
                  ? const Center(child: Text('No trees registered yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _trees.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final tree = _trees[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF388E3C),
                            child: Icon(Icons.forest, color: Colors.white),
                          ),
                          title: Text(tree.treeNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: tree.notes != null ? Text(tree.notes!) : null,
                          trailing: const Icon(Icons.camera_alt, color: Colors.green),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CameraScreen(tree: tree)),
                          ),
                        );
                      },
                    ),
    );
  }
}
