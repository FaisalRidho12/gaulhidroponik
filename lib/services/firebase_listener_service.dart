import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'notification_service.dart';

class FirebaseListenerService {
  late DatabaseReference _volumeAirRef;
  StreamSubscription<DatabaseEvent>? _volumeAirSubscription;
  bool _notified = false;

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

        if (volume < 20 && !_notified) {
          NotificationService.showNotification(
            'Peringatan Volume Air',
            'Volume air kurang, segera isi ulang!',
          );
          _notified = true;
        } else if (volume >= 20 && _notified) {
          _notified = false;
        }
      }
    });
  }

  void stopListening() {
    _volumeAirSubscription?.cancel();
  }
}
