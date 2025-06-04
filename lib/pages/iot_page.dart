import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'iot_pages/iot_monitoring_page.dart';
import 'iot_pages/iot_controlling_page.dart';

class IotPage extends StatelessWidget {
  const IotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IoT',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tambahan elemen dekoratif (ikon tanaman)
            const Icon(Icons.local_florist, color: Colors.white, size: 60),
            const SizedBox(height: 30),

            // Baris tombol (horizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Monitoring
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IotMonitoringPage()),
                    );
                  },
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  label: const Text('Monitoring'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Tombol Controlling
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IotControllingPage()),
                    );
                  },
                  icon: const Icon(Icons.tune, color: Colors.white),
                  label: const Text('Controlling'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
