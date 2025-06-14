import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class FirebaseListenerService {
  late DatabaseReference _volumeAirRef;
  Timer? _timer;

  String? _lastVolumeNotifTime;
  String? _lastTdsLowNotifTime;
  String? _lastTdsHighNotifTime;
  final int tdsNotifIntervalMinutes = 5; // Notif TDS tiap 5 menit jika masih tidak sesuai

  void startListening() {
    _volumeAirRef = FirebaseDatabase.instance.ref('/hidroponik/monitoring/volume_air');

    final DatabaseReference modeRef = FirebaseDatabase.instance.ref('/hidroponik/control/mode');
    final DatabaseReference selectedPlantRef = FirebaseDatabase.instance.ref('/hidroponik/control/selectedPlant');
    final DatabaseReference tdsMinRef = FirebaseDatabase.instance.ref('/hidroponik/jenisTanaman/tds_min');
    final DatabaseReference tdsMaxRef = FirebaseDatabase.instance.ref('/hidroponik/jenisTanaman/tds_max');
    final DatabaseReference tdsRef = FirebaseDatabase.instance.ref('/hidroponik/monitoring/tds');

    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      final currentHHmm = DateFormat('HH:mm').format(now);
      final fullDateTime = DateFormat('yyyy-MM-dd HH:mm').format(now);

      final prefs = await SharedPreferences.getInstance();
      final targetTimes = prefs.getStringList('target_times') ?? [];

      // === NOTIFIKASI VOLUME AIR ===
      if (targetTimes.contains(currentHHmm) && _lastVolumeNotifTime != fullDateTime) {
        final snapshot = await _volumeAirRef.get();
        final data = snapshot.value;

        if (data != null) {
          try {
            final volume = double.parse(data.toString());

            if (volume < 16) {
              final title = 'Peringatan Volume Air';
              final message = 'Volume air kurang, segera isi ulang!';

              NotificationService.showNotification(
                title,
                message,
                payload: 'go_to_monitoring',
                channelId: 'volume_air_channel',
                channelName: 'Volume Air Notif',
              );
              _saveNotification(title, message);
              _lastVolumeNotifTime = fullDateTime;
            }
          } catch (e) {
            print('Parsing error volume air: $e');
          }
        }
      }

      // === NOTIFIKASI PPM NUTRISI ===
      try {
        final modeSnapshot = await modeRef.get();
        final selectedPlantSnapshot = await selectedPlantRef.get();

        final mode = modeSnapshot.value?.toString().toLowerCase() ?? '';
        final selectedPlant = selectedPlantSnapshot.value?.toString().toLowerCase() ?? '';

        if (mode == 'otomatis' && selectedPlant.isNotEmpty) {
          final tdsMinPath = '/hidroponik/jenisTanaman/$selectedPlant/tds_min';
          final tdsMaxPath = '/hidroponik/jenisTanaman/$selectedPlant/tds_max';

          final tdsMinSnapshot = await FirebaseDatabase.instance.ref(tdsMinPath).get();
          final tdsMaxSnapshot = await FirebaseDatabase.instance.ref(tdsMaxPath).get();
          final tdsNowSnapshot = await tdsRef.get();

          final tdsMin = double.tryParse(tdsMinSnapshot.value.toString()) ?? 0;
          final tdsMax = double.tryParse(tdsMaxSnapshot.value.toString()) ?? 0;
          final tdsNow = double.tryParse(tdsNowSnapshot.value.toString()) ?? 0;

          final fullDateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

          if (tdsNow < tdsMin) {
            if (_shouldNotify(_lastTdsLowNotifTime, now, tdsNotifIntervalMinutes)) {
              final title = 'Peringatan Ppm Nutrisi';
              final message = 'Nutrisi untuk $selectedPlant kurang, segera tambah nutrisi!';

              NotificationService.showNotification(
                title,
                message,
                payload: 'go_to_monitoring',
                channelId: 'nutrisi_channel',
                channelName: 'Nutrisi Notif',
              );
              _saveNotification(title, message);
              _lastTdsLowNotifTime = fullDateTime;
            }
          } else if (tdsNow > tdsMax) {
            if (_shouldNotify(_lastTdsHighNotifTime, now, tdsNotifIntervalMinutes)) {
              final title = 'Peringatan Ppm Nutrisi';
              final message = 'Nutrisi untuk $selectedPlant terlalu tinggi, segera kurangi nutrisi!';

              NotificationService.showNotification(
                title,
                message,
                payload: 'go_to_monitoring',
                channelId: 'nutrisi_channel',
                channelName: 'Nutrisi Notif',
              );
              _saveNotification(title, message);
              _lastTdsHighNotifTime = fullDateTime;
            }
          }
        }
      } catch (e) {
        print('Error saat pengecekan PPM nutrisi: $e');
      }
    });
  }

  void stopListening() {
    _timer?.cancel();
  }

  Future<void> _saveNotification(String title, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final String? notifJson = prefs.getString('saved_notifications');
    List<dynamic> notifList = notifJson != null ? jsonDecode(notifJson) : [];

    notifList.add({
      'title': title,
      'message': message,
      'datetime': DateTime.now().toIso8601String(),
    });

    await prefs.setString('saved_notifications', jsonEncode(notifList));
  }

  bool _shouldNotify(String? lastTime, DateTime now, int intervalMinutes) {
    if (lastTime == null) return true;

    final lastDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(lastTime);
    return now.difference(lastDateTime).inMinutes >= intervalMinutes;
  }
}
