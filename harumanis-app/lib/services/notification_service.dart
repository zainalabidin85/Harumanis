import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../l10n/l10n.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      'ripeness_reminders',
      'Ripeness Reminders',
      description: 'Notifies you when your Harumanis is ready to eat',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Text is passed in already translated: the notification fires later,
  /// outside any widget, in the language chosen when it was scheduled.
  static Future<void> scheduleRipenessReminder({
    required int farmId,
    required DateTime purchaseDate,
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
    int ripeDays = 4,
  }) async {
    await init();

    final readyDate = purchaseDate.add(Duration(days: ripeDays));
    final scheduledTime = tz.TZDateTime(
      tz.local,
      readyDate.year,
      readyDate.month,
      readyDate.day,
      9, // 9am
    );

    // If the scheduled time is already past, notify in 5 seconds
    final notifyTime = scheduledTime.isBefore(tz.TZDateTime.now(tz.local))
        ? tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5))
        : scheduledTime;

    await _plugin.zonedSchedule(
      id: farmId,
      title: title,
      body: body,
      scheduledDate: notifyTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'ripeness_reminders',
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id: id);
}

Future<void> showReminderSheet(
  BuildContext context, {
  required int farmId,
  required String farmName,
  int ripeDays = 4,
}) async {
  await NotificationService.init();
  final granted = await NotificationService.requestPermission();
  if (!granted && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.reminderAllowNotifications)),
    );
    return;
  }

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReminderSheet(
      farmName: farmName,
      farmId: farmId,
      initialDate: DateTime.now(),
      ripeDays: ripeDays,
    ),
  );
}

class _ReminderSheet extends StatefulWidget {
  final String farmName;
  final int farmId;
  final DateTime initialDate;
  final int ripeDays;

  const _ReminderSheet({
    required this.farmName,
    required this.farmId,
    required this.initialDate,
    this.ripeDays = 4,
  });

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late DateTime _purchaseDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _purchaseDate = widget.initialDate;
  }

  String _formatDate(DateTime d) =>
      DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode).format(d);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3)),
      lastDate: DateTime.now(),
      helpText: context.l10n.reminderPickerHelp,
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    final l10n = context.l10n;
    try {
      await NotificationService.scheduleRipenessReminder(
        farmId: widget.farmId,
        purchaseDate: _purchaseDate,
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody(widget.farmName),
        channelName: l10n.reminderChannelName,
        channelDescription: l10n.reminderChannelDescription,
        ripeDays: widget.ripeDays,
      );
      if (mounted) {
        final readyDate = _purchaseDate.add(Duration(days: widget.ripeDays));
        final readyText = _formatDate(readyDate);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.reminderSet(readyText)),
            backgroundColor: const Color(0xFF166534),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reminderErrorSet(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final readyDate = _purchaseDate.add(Duration(days: widget.ripeDays));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('🥭', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.reminderSheetTitle,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              fontFamily: 'Poppins')),
                      Text(widget.farmName,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Poppins')),
                    ]),
              ),
            ]),
            const SizedBox(height: 24),

            Text(context.l10n.reminderPurchaseQuestion,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    fontFamily: 'Poppins')),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFFD97706), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFFFBEB),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Color(0xFFB45309), size: 18),
                  const SizedBox(width: 12),
                  Text(_formatDate(_purchaseDate),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF78350F),
                          fontFamily: 'Poppins')),
                  const Spacer(),
                  Text(context.l10n.reminderChange,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB45309),
                          fontFamily: 'Poppins')),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Color(0xFF16A34A), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.reminderExplanation(_formatDate(readyDate), widget.ripeDays),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF166534),
                        fontFamily: 'Poppins'),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.alarm_add_rounded),
                label: Text(_saving ? context.l10n.reminderSetting : context.l10n.reminderSetButton),
                onPressed: _saving ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166634),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
