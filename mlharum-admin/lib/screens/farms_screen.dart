import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({super.key});
  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  List<dynamic> _farms = [];
  bool _loading = true;
  String? _error;
  bool? _publicFilter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _farms = await ApiService.getFarms(isPublic: _publicFilter);
    } on DioException catch (e) {
      _error = 'Failed (error ${e.response?.statusCode}).';
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showActions(Map<String, dynamic> farm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FarmSheet(farm: farm, onDone: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _filterChip('All', null),
            const SizedBox(width: 8),
            _filterChip('Public', true),
            const SizedBox(width: 8),
            _filterChip('Private', false),
          ]),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: GoogleFonts.poppins(color: kRed)))
                : _farms.isEmpty
                    ? Center(child: Text('No farms found.', style: GoogleFonts.poppins(color: kText3)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _farms.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _FarmTile(farm: _farms[i], onTap: () => _showActions(_farms[i])),
                        ),
                      ),
      ),
    ]);
  }

  Widget _filterChip(String label, bool? value) {
    final selected = _publicFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) { setState(() => _publicFilter = value); _load(); },
      selectedColor: kIndigo100,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: selected ? kIndigo700 : kText2),
    );
  }
}

class _FarmTile extends StatelessWidget {
  final Map<String, dynamic> farm;
  final VoidCallback onTap;
  const _FarmTile({required this.farm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPublic = farm['is_public'] as bool? ?? false;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow,
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isPublic ? kGreen.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.agriculture_rounded, color: isPublic ? kGreen : kText3, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(farm['name'] as String,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: kText1)),
              Text(farm['owner_name'] as String,
                  style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
              const SizedBox(height: 4),
              Row(children: [
                _badge(isPublic ? 'Public' : 'Private', isPublic ? kGreen : kText3),
                if (farm['price_per_kg'] != null) ...[
                  const SizedBox(width: 6),
                  _badge('RM ${(farm['price_per_kg'] as num).toStringAsFixed(2)}/kg', kIndigo700),
                ],
                const SizedBox(width: 6),
                _badge('${farm['tree_count']} trees', kText2),
              ]),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: kText3),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _FarmSheet extends StatefulWidget {
  final Map<String, dynamic> farm;
  final VoidCallback onDone;
  const _FarmSheet({required this.farm, required this.onDone});
  @override
  State<_FarmSheet> createState() => _FarmSheetState();
}

class _FarmSheetState extends State<_FarmSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _toggle(bool isPublic) async {
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.updateFarm(widget.farm['id'] as int, isPublic: isPublic);
      if (mounted) { Navigator.pop(context); widget.onDone(); }
    } on DioException catch (e) {
      setState(() { _error = 'Failed (error ${e.response?.statusCode}).'; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final farm = widget.farm;
    final isPublic = farm['is_public'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(farm['name'] as String,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        Text('Owner: ${farm['owner_name']}', style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
        if (farm['location'] != null)
          Text('Location: ${farm['location']}', style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
        const SizedBox(height: 16),
        if (_error != null) Text(_error!, style: GoogleFonts.poppins(fontSize: 13, color: kRed)),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            child: isPublic
                ? OutlinedButton.icon(
                    onPressed: () => _toggle(false),
                    icon: const Icon(Icons.visibility_off_outlined, size: 16, color: kRed),
                    label: Text('Make Private', style: GoogleFonts.poppins(color: kRed, fontSize: 14)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: kRed)),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _toggle(true),
                    icon: const Icon(Icons.storefront_rounded, size: 16),
                    label: const Text('Make Public'),
                  ),
          ),
      ]),
    );
  }
}
