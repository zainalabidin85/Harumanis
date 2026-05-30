import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class FarmPhotosScreen extends StatefulWidget {
  const FarmPhotosScreen({super.key});

  @override
  State<FarmPhotosScreen> createState() => _FarmPhotosScreenState();
}

class _FarmPhotosScreenState extends State<FarmPhotosScreen> {
  List<Map<String, dynamic>> _images = [];
  bool _loading = true;
  bool _uploading = false;
  int? _farmId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _farmId = await AuthService.getFarmId();
    if (_farmId != null) {
      await _load();
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _load() async {
    if (_farmId == null) return;
    setState(() => _loading = true);
    try {
      final imgs = await ApiService.getFarmImages(_farmId!);
      if (mounted) setState(() => _images = imgs);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick() async {
    if (_images.length >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1920);
    if (picked == null || !mounted) return;

    String caption = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add caption',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'e.g. Harumanis Season 2025 (optional)',
            ),
            onChanged: (v) => caption = v,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Upload')),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    HapticFeedback.mediumImpact();
    setState(() => _uploading = true);
    try {
      await ApiService.uploadFarmImage(_farmId!, picked.path, caption.trim());
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed. Please try again.',
              style: GoogleFonts.poppins())),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> img) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete photo?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('This photo will be permanently removed.',
            style: GoogleFonts.poppins(fontSize: 13, color: kText2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: kRed),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteFarmImage(_farmId!, img['id'] as int);
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text('Farm Photos',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: kGreenPrimary,
        foregroundColor: Colors.white,
        actions: [
          if (_uploading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))),
            )
          else if (_images.length < 5)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: 'Add photo',
              onPressed: _pick,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _farmId == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store_mall_directory_outlined,
                            size: 64, color: kText3),
                        const SizedBox(height: 16),
                        Text('No farm set up yet',
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: kText2)),
                        const SizedBox(height: 6),
                        Text('Create your farm profile first.',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: kText3)),
                      ],
                    ),
                  ),
                )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_images.length}/5 photos',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: kText2, fontWeight: FontWeight.w500)),
                      if (_images.length < 5)
                        Text('Tap + to add a photo',
                            style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
                    ],
                  ),
                ),
                if (_images.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 64, color: kText3),
                          const SizedBox(height: 16),
                          Text('No photos yet',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: kText2)),
                          const SizedBox(height: 6),
                          Text('Add up to 5 photos to attract buyers',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: kText3)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: const Text('Add Photo'),
                            onPressed: _pick,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: _images.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => _PhotoCard(
                          img: _images[i], onDelete: () => _delete(_images[i])),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final Map<String, dynamic> img;
  final VoidCallback onDelete;
  const _PhotoCard({required this.img, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final caption = img['caption'] as String?;
    return Container(
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: kCardShadow),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: (img['thumb_url'] ?? img['url']) as String,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    height: 220,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                errorWidget: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(child: Icon(Icons.broken_image_rounded, color: kText3, size: 48))),
              ),
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          if (caption != null && caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Text(caption,
                  style: GoogleFonts.poppins(fontSize: 13, color: kText1)),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}
