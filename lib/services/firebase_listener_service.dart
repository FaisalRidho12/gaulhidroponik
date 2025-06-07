import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class FirebaseListenerService {
  late DatabaseReference _volumeAirRef;
  Timer? _timer;
  String? _lastNotifiedTime; // Format: "yyyy-MM-dd HH:mm"

  void startListening() {
    _volumeAirRef = FirebaseDatabase.instance.ref('/hidroponik/monitoring/volume_air');

    // Cek setiap 1 menit
    _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final now = DateTime.now();
      final currentHHmm = DateFormat('HH:mm').format(now);
      final fullDateTime = DateFormat('yyyy-MM-dd HH:mm').format(now);

      final prefs = await SharedPreferences.getInstance();
      final targetTimes = prefs.getStringList('target_times') ?? [];

      if (targetTimes.contains(currentHHmm) && _lastNotifiedTime != fullDateTime) {
        final snapshot = await _volumeAirRef.get();
        final data = snapshot.value;

        if (data != null) {
          double volume = 0;
          try {
            volume = double.parse(data.toString());
          } catch (e) {
            print('Parsing error: $e');
            return;
          }

          if (volume < 16) {
            final title = 'Peringatan Volume Air';
            final message = 'Volume air kurang, segera isi ulang!';

            NotificationService.showNotification(title, message, payload: 'go_to_monitoring');
            _saveNotification(title, message);
            _lastNotifiedTime = fullDateTime; // Simpan waktu notifikasi terakhir
          }
        }
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
}
