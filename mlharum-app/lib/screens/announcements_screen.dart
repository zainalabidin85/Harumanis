import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'announcement_detail_screen.dart';
import 'announcement_editor_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> _announcements = [];
  bool _loading = true;
  String? _error;
  bool _upcomingOnly = false;
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _canPost = role == 'doa' || role == 'admin');
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final announcements = await ApiService.getAnnouncements(upcoming: _upcomingOnly);
      if (mounted) setState(() => _announcements = announcements);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to load announcements: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setFilter(bool upcomingOnly) {
    setState(() => _upcomingOnly = upcomingOnly);
    _load();
  }

  Future<void> _openEditor() async {
    final created = await Navigator.push<bool>(
      context,
      FadeSlideRoute(page: const AnnouncementEditorScreen()),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          if (_canPost)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Post announcement',
              onPressed: _openEditor,
            ),
        ],
      ),
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
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: !_upcomingOnly,
                  onSelected: (_) => _setFilter(false),
                  selectedColor: kGreenPrimary,
                  backgroundColor: kCard,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: !_upcomingOnly ? Colors.white : kText1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: !_upcomingOnly ? kGreenPrimary : kDivider),
                  ),
                ),
              ),
              ChoiceChip(
                label: const Text('Upcoming'),
                selected: _upcomingOnly,
                onSelected: (_) => _setFilter(true),
                selectedColor: kGreenPrimary,
                backgroundColor: kCard,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _upcomingOnly ? Colors.white : kText1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _upcomingOnly ? kGreenPrimary : kDivider),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_announcements.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No announcements yet.', style: GoogleFonts.poppins(color: kText3)),
            ),
          )
        else
          ..._announcements.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AnnouncementCard(
                  announcement: a,
                  onTap: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      FadeSlideRoute(page: AnnouncementDetailScreen(announcement: a)),
                    );
                    if (changed == true) _load();
                  },
                ),
              )),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (announcement.imageUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: announcement.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: kGreenLight),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: kText1),
                    ),
                    const SizedBox(height: 6),
                    if (announcement.eventDate != null || announcement.location != null)
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (announcement.eventDate != null)
                            _MetaRow(
                              icon: Icons.event_rounded,
                              text: DateFormat('d MMM y, h:mm a').format(announcement.eventDate!),
                            ),
                          if (announcement.location != null)
                            _MetaRow(icon: Icons.place_rounded, text: announcement.location!),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13, color: kText2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: kText3),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.poppins(fontSize: 11, color: kText3)),
      ],
    );
  }
}
