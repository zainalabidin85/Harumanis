import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doa_report.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../l10n/l10n.dart';

class DoaReportScreen extends StatefulWidget {
  const DoaReportScreen({super.key});

  @override
  State<DoaReportScreen> createState() => _DoaReportScreenState();
}

class _DoaReportScreenState extends State<DoaReportScreen> {
  DoaYieldReport? _report;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  int? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final report = await ApiService.getDoaYieldReport(season: _selectedSeason);
      if (mounted) setState(() => _report = report);
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.doaReportErrorLoad(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectSeason(int season) {
    setState(() => _selectedSeason = season);
    _load();
  }

  Future<void> _setOwnerVerified(int ownerId, bool isVerified) async {
    try {
      await ApiService.setOwnerVerified(ownerId, isVerified);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.doaReportErrorVerify(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: Text(context.l10n.homeDoaMonitorTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(_error!, style: GoogleFonts.poppins(color: kText2))),
                    ],
                  )
                : _buildContent(_report!),
      ),
    );
  }

  Widget _buildContent(DoaYieldReport report) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredFarms = query.isEmpty
        ? report.farms
        : report.farms.where((farm) {
            return farm.farmName.toLowerCase().contains(query) ||
                farm.ownerName.toLowerCase().contains(query) ||
                (farm.location?.toLowerCase().contains(query) ?? false);
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          context.l10n.doaReportSeasonAllFarms('${report.currentSeason}'),
          style: GoogleFonts.poppins(fontSize: 13, color: kText2),
        ),
        if (report.availableSeasons.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: report.availableSeasons.map((season) {
                final selected = season == report.currentSeason;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(season.toString()),
                    selected: selected,
                    onSelected: (_) => _selectSeason(season),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : kText1,
                    ),
                    selectedColor: kGreenPrimary,
                    backgroundColor: kCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: selected ? kGreenPrimary : kDivider),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _SummaryGrid(report: report),
        const SizedBox(height: 24),
        Text(context.l10n.doaReportYieldByStage, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
        const SizedBox(height: 12),
        _StageBreakdownCard(stages: report.stageSummary),
        const SizedBox(height: 24),
        Text(context.l10n.doaReportByFarm(report.farms.length), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1)),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: context.l10n.doaReportSearchHint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: kText3),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: kCard,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...filteredFarms.map((farm) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FarmCard(farm: farm, onVerifyChanged: _setOwnerVerified),
            )),
        if (report.farms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(context.l10n.doaReportNoFarms, style: GoogleFonts.poppins(color: kText3)),
            ),
          )
        else if (filteredFarms.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(context.l10n.doaReportNoMatch(_searchQuery), style: GoogleFonts.poppins(color: kText3)),
            ),
          ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final DoaYieldReport report;
  const _SummaryGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    final items = [
      (context.l10n.doaReportStatFarms, report.totalFarms.toString(), kGreenPrimary),
      (context.l10n.dashboardStatTrees, report.totalTrees.toString(), const Color(0xFF0369A1)),
      (context.l10n.doaReportStatActiveFruits, report.totalActiveFruits.toString(), kOrange),
      (context.l10n.dashboardStatHarvested, report.totalHarvestedFruits.toString(), const Color(0xFF7C3AED)),
      (context.l10n.doaReportStatLostAborted, report.totalAbortedFruits.toString(), const Color(0xFFDC2626)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: items.map((item) {
        final (label, value, color) = item;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StageBreakdownCard extends StatelessWidget {
  final List<DoaStageCount> stages;
  const _StageBreakdownCard({required this.stages});

  @override
  Widget build(BuildContext context) {
    final total = stages.fold<int>(0, (sum, s) => sum + s.count);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: stages.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(context.l10n.doaReportNoActiveFruits, style: GoogleFonts.poppins(color: kText3)),
            )
          : Column(
              children: stages.map((stage) {
                final fraction = total == 0 ? 0.0 : stage.count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(stageName(context.l10n, stage.stage), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: kText1)),
                          Text('${stage.count}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: kGreenPrimary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 6,
                          backgroundColor: kDivider,
                          valueColor: const AlwaysStoppedAnimation(kGreenPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _FarmCard extends StatefulWidget {
  final DoaFarmSummary farm;
  final Future<void> Function(int ownerId, bool isVerified) onVerifyChanged;
  const _FarmCard({required this.farm, required this.onVerifyChanged});

  @override
  State<_FarmCard> createState() => _FarmCardState();
}

class _FarmCardState extends State<_FarmCard> {
  bool _updating = false;

  Future<void> _toggleVerified() async {
    setState(() => _updating = true);
    await widget.onVerifyChanged(widget.farm.ownerId, !widget.farm.isVerified);
    if (mounted) setState(() => _updating = false);
  }

  @override
  Widget build(BuildContext context) {
    final farm = widget.farm;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(farm.farmName, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: kText1)),
              ),
              GestureDetector(
                onTap: _updating ? null : _toggleVerified,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: farm.isVerified ? kGreenLight : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _updating
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          farm.isVerified ? context.l10n.doaReportVerified : context.l10n.doaReportNotVerified,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: farm.isVerified ? kGreenPrimary : Colors.orange.shade800,
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (farm.location != null && farm.location!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(farm.location!, style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.person_outline_rounded, size: 14, color: kText3),
              Text(farm.ownerName, style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
              if (farm.ownerPhone != null && farm.ownerPhone!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(Icons.phone_outlined, size: 14, color: kText3),
                Text(farm.ownerPhone!, style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _MiniStat(label: context.l10n.dashboardStatTrees, value: farm.totalTrees),
              _MiniStat(label: context.l10n.dashboardStatActive, value: farm.activeFruits),
              _MiniStat(label: context.l10n.dashboardStatHarvested, value: farm.harvestedFruits),
              _MiniStat(label: context.l10n.doaReportStatLost, value: farm.abortedFruits),
            ],
          ),
          if (farm.stageCounts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: farm.stageCounts.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGreenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.l10n.doaReportStageCount(stageName(context.l10n, s.stage), s.count),
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: kGreenPrimary),
                    ),
                  )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: kText1)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
      ],
    );
  }
}
