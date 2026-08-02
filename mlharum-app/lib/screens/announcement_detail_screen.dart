import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/page_route.dart';
import 'announcement_editor_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  late Announcement _announcement;
  bool _canManage = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _announcement = widget.announcement;
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _canManage = role == 'doa' || role == 'admin');
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<bool>(
      context,
      FadeSlideRoute(page: AnnouncementEditorScreen(existing: _announcement)),
    );
    if (updated == true && mounted) {
      final refreshed = await ApiService.getAnnouncement(_announcement.id);
      if (mounted) setState(() => _announcement = refreshed);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete announcement?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('This can\'t be undone.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await ApiService.deleteAnnouncement(_announcement.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete. Please try again.', style: GoogleFonts.poppins())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcement = _announcement;
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: announcement.imageUrl != null ? 220 : 0,
            backgroundColor: kGreenPrimary,
            actions: [
              if (_canManage)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: _deleting ? null : _edit,
                ),
              if (_canManage)
                IconButton(
                  icon: _deleting
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: _deleting ? null : _delete,
                ),
            ],
            flexibleSpace: announcement.imageUrl != null
                ? FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: announcement.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: kGreenLight),
                    ),
                  )
                : null,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  announcement.title,
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: kText1),
                ),
                const SizedBox(height: 12),
                if (announcement.eventDate != null || announcement.location != null)
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (announcement.eventDate != null)
                        _MetaChip(
                          icon: Icons.event_rounded,
                          text: DateFormat('EEEE, d MMM y · h:mm a').format(announcement.eventDate!),
                        ),
                      if (announcement.location != null)
                        _MetaChip(icon: Icons.place_rounded, text: announcement.location!),
                    ],
                  ),
                const SizedBox(height: 20),
                Text(
                  announcement.body,
                  style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: kText1),
                ),
                const SizedBox(height: 20),
                Text(
                  'Posted ${DateFormat('d MMM y').format(announcement.createdAt)} · DOA Perlis',
                  style: GoogleFonts.poppins(fontSize: 11, color: kText3),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kGreenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kGreenPrimary),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: kGreenPrimary)),
        ],
      ),
    );
  }
}
