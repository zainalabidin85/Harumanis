import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';
import '../theme.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: announcement.imageUrl != null ? 220 : 0,
            backgroundColor: kGreenPrimary,
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
