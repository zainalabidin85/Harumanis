import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';
import '../theme.dart';

class AnnouncementEditorScreen extends StatefulWidget {
  final Announcement? existing;

  const AnnouncementEditorScreen({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  State<AnnouncementEditorScreen> createState() => _AnnouncementEditorScreenState();
}

class _AnnouncementEditorScreenState extends State<AnnouncementEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _eventDate;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleCtrl.text = existing.title;
      _bodyCtrl.text = existing.body;
      _locationCtrl.text = existing.location ?? '';
      _eventDate = existing.eventDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1920);
    if (picked == null || !mounted) return;
    setState(() => _imagePath = picked.path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate ?? now),
    );
    if (!mounted) return;
    setState(() => _eventDate = DateTime(
          date.year, date.month, date.day,
          time?.hour ?? 9, time?.minute ?? 0,
        ));
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title and description are required.', style: GoogleFonts.poppins())),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.isEditing) {
        await ApiService.updateAnnouncement(
          id: widget.existing!.id,
          title: title,
          body: body,
          eventDate: _eventDate,
          location: _locationCtrl.text.trim(),
        );
      } else {
        await ApiService.createAnnouncement(
          title: title,
          body: body,
          eventDate: _eventDate,
          location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
          imagePath: _imagePath,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              widget.isEditing
                  ? 'Failed to save changes. Please try again.'
                  : 'Failed to post announcement. Please try again.',
              style: GoogleFonts.poppins())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Announcement' : 'Post Announcement',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          if (!widget.isEditing)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kDivider),
                  image: _imagePath != null
                      ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _imagePath == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 32, color: kText3),
                            const SizedBox(height: 8),
                            Text('Add banner image (optional)',
                                style: GoogleFonts.poppins(fontSize: 13, color: kText3)),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          if (widget.isEditing && widget.existing!.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Banner image can\'t be changed here — delete and repost to change it.',
                  style: GoogleFonts.poppins(fontSize: 12, color: kText3)),
            ),
          if (!widget.isEditing || widget.existing!.imageUrl != null) const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            maxLength: 150,
            decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Free Harumanis Grafting Workshop'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 6,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Details farmers need to know',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Location (optional)', hintText: 'e.g. Pejabat DOA Perlis'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Event date (optional)'),
              child: Text(
                _eventDate != null
                    ? DateFormat('EEEE, d MMM y · h:mm a').format(_eventDate!)
                    : 'No specific date — general notice',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _eventDate != null ? kText1 : kText3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(widget.isEditing ? 'Save Changes' : 'Post Announcement'),
          ),
        ],
      ),
    );
  }
}
