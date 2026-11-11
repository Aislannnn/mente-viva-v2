import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/home/domain/entities.dart';

final reminderNotifications = ReminderNotifications();

class ReminderNotifications {
  final enabled = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  SharedPreferences? _prefs;
  bool _initialized = false;
  Future<void> _lastSync = Future<void>.value();
  int _revision = 0;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (!supported || _initialized) return;
    tz.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _prefs = await SharedPreferences.getInstance();
    enabled.value = _prefs!.getBool('reminder_notifications_enabled') ?? false;
    _initialized = true;
  }

  Future<bool> enable(List<Lembrete> reminders) async {
    if (!supported || !_initialized) return false;
    final granted = defaultTargetPlatform == TargetPlatform.android
        ? await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission()
        : await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true);
    if (granted != true) return false;
    await _prefs!.setBool('reminder_notifications_enabled', true);
    enabled.value = true;
    await sync(reminders, assistedAccount: true);
    if (error.value != null) {
      await disable();
      return false;
    }
    return true;
  }

  Future<void> disable() async {
    if (!supported || !_initialized) return;
    await _prefs!.setBool('reminder_notifications_enabled', false);
    enabled.value = false;
    await sync(const [], assistedAccount: false);
  }

  Future<void> sync(List<Lembrete> reminders, {required bool assistedAccount}) {
    if (!supported || !_initialized) return Future<void>.value();
    final revision = ++_revision;
    final entries = [
      for (final reminder in reminders)
        (
          title: reminder.titulo,
          body: reminder.descricao,
          time: reminder.horario,
        ),
    ];
    _lastSync = _lastSync.then((_) async {
      if (revision != _revision) return;
      try {
        error.value = null;
        await _plugin.cancelAll();
        if (!enabled.value || !assistedAccount) return;
        await _schedule(entries);
      } catch (_) {
        error.value = 'Não foi possível programar os alertas neste aparelho.';
      }
    });
    return _lastSync;
  }

  Future<void> _schedule(
    List<({String title, String body, String time})> entries,
  ) async {
    // iOS keeps at most 64 pending notifications. Leave room for system limits.
    for (var index = 0; index < entries.length && index < 60; index++) {
      final reminder = entries[index];
      final parts = reminder.time.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null ||
          minute == null ||
          hour > 23 ||
          minute > 59 ||
          hour < 0 ||
          minute < 0)
        continue;
      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!next.isAfter(now)) {
        next = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + 1,
          hour,
          minute,
        );
      }
      await _plugin.zonedSchedule(
        1000 + index,
        reminder.title,
        reminder.body.isEmpty ? 'Hora do seu lembrete' : reminder.body,
        next,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Lembretes diários',
            channelDescription: 'Alertas da rotina da Pessoa Assistida',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
