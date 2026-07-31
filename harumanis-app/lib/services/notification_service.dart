import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

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

  static Future<void> scheduleRipenessReminder({
    required int farmId,
    required String farmName,
    required DateTime purchaseDate,
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
      title: '🥭 Your Harumanis is ready to eat!',
      body:
          'The Harumanis from $farmName you bought is now at its sweetest. Enjoy!',
      scheduledDate: notifyTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'ripeness_reminders',
          'Ripeness Reminders',
          channelDescription:
              'Notifies you when your Harumanis is ready to eat',
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
      const SnackBar(
          content:
              Text('Please allow notifications to set a reminder.')),
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

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3)),
      lastDate: DateTime.now(),
      helpText: 'When did you buy the fruit?',
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      await NotificationService.scheduleRipenessReminder(
        farmId: widget.farmId,
        farmName: widget.farmName,
        purchaseDate: _purchaseDate,
        ripeDays: widget.ripeDays,
      );
      if (mounted) {
        Navigator.pop(context);
        final readyDate = _purchaseDate.add(Duration(days: widget.ripeDays));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder set! We\'ll notify you on ${_formatDate(readyDate)} at 9am.'),
            backgroundColor: const Color(0xFF166534),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not set reminder: $e')),
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
                      const Text('Set Ripeness Reminder',
                          style: TextStyle(
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

            const Text('When did you buy this fruit?',
                style: TextStyle(
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
                  const Text('Change',
                      style: TextStyle(
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
                    'We\'ll remind you on ${_formatDate(readyDate)} at 9am — ${widget.ripeDays} days after purchase when Harumanis is sweetest.',
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
                label: Text(_saving ? 'Setting...' : 'Set Reminder'),
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
