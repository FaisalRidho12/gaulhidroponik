import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class FirebaseListenerService {
  late DatabaseReference _volumeAirRef;
  StreamSubscription<DatabaseEvent>? _volumeAirSubscription;

  // Simpan jam:menit notifikasi terakhir agar tidak duplikat dalam 1 menit
  String? _lastNotifiedHHmm;

  void startListening() {
    _volumeAirRef = FirebaseDatabase.instance.ref('/hidroponik/monitoring/volume_air');

    _volumeAirSubscription = _volumeAirRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        double volume = 0;
        try {
          volume = double.parse(data.toString());
        } catch (e) {
          print('Parsing volume_air error: $e');
          return;
        }

        final now = DateTime.now();
        final currentHHmm = DateFormat('HH:mm').format(now); // contoh: 07:00

        // Waktu target notifikasi yang baru
        final targetTimes = ['23:16', '23:18', '23:24', '23:25'];

        if (targetTimes.contains(currentHHmm) && _lastNotifiedHHmm != currentHHmm) {
          if (volume < 16) {
            final title = 'Peringatan Volume Air';
            final message = 'Volume air kurang, segera isi ulang!';

            NotificationService.showNotification(
              title,
              message,
              payload: 'go_to_monitoring',
            );

            // Simpan notifikasi ke SharedPreferences
            _saveNotification(title, message);

            _lastNotifiedHHmm = currentHHmm;
          }
        }
      }
    });
  }

  void stopListening() {
    _volumeAirSubscription?.cancel();
  }

  Future<void> _saveNotification(String title, String message) async {
    final prefs = await SharedPreferences.getInstance();

    final String? notifJson = prefs.getString('saved_notifications');
    List<dynamic> notifList = [];

    if (notifJson != null) {
      notifList = jsonDecode(notifJson);
    }

    // Tambahkan notifikasi baru
    notifList.add({
      'title': title,
      'message': message,
      'datetime': DateTime.now().toIso8601String(),
    });

    await prefs.setString('saved_notifications', jsonEncode(notifList));
  }
}
