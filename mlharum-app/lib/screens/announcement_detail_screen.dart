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
import '../l10n/l10n.dart';

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
        title: Text(context.l10n.announcementDetailDeleteTitle, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(context.l10n.commonCantBeUndone, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.commonDelete, style: GoogleFonts.poppins(color: Colors.red)),
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
          SnackBar(content: Text(context.l10n.announcementDetailErrorDelete, style: GoogleFonts.poppins())),
        );
      }
    }
  }

  void _openImage() {
    final url = _announcement.imageUrl;
    if (url == null) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(imageUrl: url, heroTag: 'announcement-${_announcement.id}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcement = _announcement;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kText1,
        actions: [
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.commonEdit,
              onPressed: _deleting ? null : _edit,
            ),
          if (_canManage)
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: kText1, strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: context.l10n.commonDelete,
              onPressed: _deleting ? null : _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
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
                    text: DateFormat('EEEE, d MMM y · h:mm a', Localizations.localeOf(context).languageCode).format(announcement.eventDate!),
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
            context.l10n.announcementDetailPosted(DateFormat('d MMM y', Localizations.localeOf(context).languageCode).format(announcement.createdAt)),
            style: GoogleFonts.poppins(fontSize: 11, color: kText3),
          ),
          if (announcement.imageUrl != null) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _openImage,
              child: Hero(
                tag: 'announcement-${announcement.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CachedNetworkImage(
                        imageUrl: announcement.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(height: 200, color: kGreenLight),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageViewer({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
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
