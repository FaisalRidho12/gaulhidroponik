import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IotMonitoringPage extends StatefulWidget {
  const IotMonitoringPage({super.key});

  @override
  _IotMonitoringPageState createState() => _IotMonitoringPageState();
}

class _IotMonitoringPageState extends State<IotMonitoringPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String tds = "Loading...";
  String volumeAir = "Loading...";
  String relay1Status = "Loading...";
  String relay2Status = "Loading...";
  String volumeNutrisiA = "Loading...";
  String volumeNutrisiB = "Loading...";

  @override
  void initState() {
    super.initState();
    loadLastSavedData();
    listenRelayStatus();
  }

  void loadLastSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tds = prefs.getString('last_tds') ?? "Klik untuk ambil data";
      volumeAir = prefs.getString('last_volume_air') ?? "Klik untuk ambil data";
      volumeNutrisiA = prefs.getString('last_volume_nutrisi_a') ?? "Klik untuk ambil data";
      volumeNutrisiB = prefs.getString('last_volume_nutrisi_b') ?? "Klik untuk ambil data";
    });
  }

  Future<void> fetchTDS() async {
    final snapshot = await _database.child('/hidroponik/monitoring/tds').get();
    if (snapshot.exists) {
      String value = snapshot.value.toString();
      setState(() {
        tds = value;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_tds', value);
    }
  }

  Future<void> fetchVolumeAir() async {
    final snapshot = await _database.child('/hidroponik/monitoring/volume_air').get();
    if (snapshot.exists) {
      String value = snapshot.value.toString();
      setState(() {
        volumeAir = value;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_volume_air', value);
    }
  }

  Future<void> fetchVolumeNutrisiA() async {
    final snapshot = await _database.child('/hidroponik/monitoring/volume_nutrisi_a').get();
    if (snapshot.exists) {
      String value = snapshot.value.toString();
      setState(() {
        volumeNutrisiA = value;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_volume_nutrisi_a', value);
    }
  }

  Future<void> fetchVolumeNutrisiB() async {
    final snapshot = await _database.child('/hidroponik/monitoring/volume_nutrisi_b').get();
    if (snapshot.exists) {
      String value = snapshot.value.toString();
      setState(() {
        volumeNutrisiB = value;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('last_volume_nutrisi_b', value);
    }
  }

  void listenRelayStatus() {
    _database.child('/hidroponik/monitoring/relay1').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          relay1Status = event.snapshot.value.toString();
        });
      }
    });

    _database.child('/hidroponik/monitoring/relay2').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          relay2Status = event.snapshot.value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102F15)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'IoT Monitoring',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 0),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: fetchTDS,
                          child: _buildCard(
                            icon: Icons.science,
                            label: 'TDS',
                            value:
                            '${double.tryParse(tds)?.toInt().toString() ?? "--"} ppm',
                            percent: ((double.tryParse(tds) ?? 0.0) / 1600.0)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: fetchVolumeAir,
                          child: _buildCard(
                            icon: Icons.water,
                            label: 'Volume',
                            value:
                            '${double.tryParse(volumeAir)?.toStringAsFixed(1) ?? "--"} L',
                            percent:
                            ((double.tryParse(volumeAir) ?? 0.0) / 18.0)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: fetchVolumeNutrisiA,
                          child: _buildCard(
                            icon: Icons.water_drop_outlined,
                            label: 'Vol. Nutrisi A',
                            value:
                            '${double.tryParse(volumeNutrisiA)?.toStringAsFixed(1) ?? "--"} L',
                            percent:
                            ((double.tryParse(volumeNutrisiA) ?? 0.0) / 2.0).clamp(0.0, 1.0), // Asumsikan max 2L
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: fetchVolumeNutrisiB,
                          child: _buildCard(
                            icon: Icons.opacity_outlined,
                            label: 'Vol. Nutrisi B',
                            value:
                            '${double.tryParse(volumeNutrisiB)?.toStringAsFixed(1) ?? "--"} L',
                            percent:
                            ((double.tryParse(volumeNutrisiB) ?? 0.0) / 2.0).clamp(0.0, 1.0), // Asumsikan max 2L
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildCard(
                          icon: Icons.water_drop,
                          label: 'Nutrisi A',
                          value: relay1Status,
                          percent: relay1Status == "ON" ? 1.0 : 0.0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCard(
                          icon: Icons.opacity,
                          label: 'Nutrisi B',
                          value: relay2Status,
                          percent: relay2Status == "ON" ? 1.0 : 0.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required String value,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: CircularPercentIndicator(
          radius: 70,
          lineWidth: 10,
          percent: percent.clamp(0.0, 1.0),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFEAF1B1), size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEAF1B1),
                ),
              ),
            ],
          ),
          progressColor: const Color(0xFF102F15),
          backgroundColor: const Color(0xFFEBFADC),
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ),
    );
  }
}
