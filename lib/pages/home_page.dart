import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:gaulhidroponik/pages/iot_pages/iot_monitoring_page.dart';
import 'package:gaulhidroponik/pages/iot_pages/iot_controlling_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? displayName;
  String selectedText = 'Memuat data...';

  final DatabaseReference _plantRef = FirebaseDatabase.instance.ref("/hidroponik/jenisTanaman/nama");
  final DatabaseReference _modeRef = FirebaseDatabase.instance.ref("/hidroponik/control/mode");
  final DatabaseReference _volumeAirRef = FirebaseDatabase.instance.ref("/hidroponik/monitoring/volume_air");
  final DatabaseReference _tdsRef = FirebaseDatabase.instance.ref("/hidroponik/monitoring/tds");
  final DatabaseReference _tdsMinRef = FirebaseDatabase.instance.ref("/hidroponik/jenisTanaman/tds_min");
  final DatabaseReference _tdsMaxRef = FirebaseDatabase.instance.ref("/hidroponik/jenisTanaman/tds_max");

  double? _tdsMin;
  double? _tdsMax;
  double? _tds;
  double? _volumeAir;

  String? _plant;
  String? _mode;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      displayName = user.displayName ?? user.email;
    }

    // Listen mode
    _modeRef.onValue.listen((event) {
      final modeValue = event.snapshot.value;
      setState(() {
        _mode = (modeValue is String && modeValue.isNotEmpty) ? modeValue.toLowerCase() : null;
        _updateSelectedText();
      });
    });

    // Listen jenis tanaman
    _plantRef.onValue.listen((event) {
      final plantValue = event.snapshot.value;
      setState(() {
        if (plantValue is String && plantValue.isNotEmpty) {
          _plant = plantValue[0].toUpperCase() + plantValue.substring(1);
        } else {
          _plant = 'Tidak diketahui';
        }
        _updateSelectedText();
      });
    });

    // Listen volume_air
    _volumeAirRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        if (value is num) {
          _volumeAir = value.toDouble();
        } else {
          _volumeAir = null;
        }
      });
    });

    // Listen TDS value
    _tdsRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        if (value is num) {
          _tds = value.toDouble();
        } else {
          _tds = null;
        }
      });
    });

    // Listen tds_min
    _tdsMinRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        if (value is num) {
          _tdsMin = value.toDouble();
        } else {
          _tdsMin = null;
        }
        _updateSelectedText(); // tambahkan ini
      });
    });

    // Listen tds_max
    _tdsMaxRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        if (value is num) {
          _tdsMax = value.toDouble();
        } else {
          _tdsMax = null;
        }
        _updateSelectedText(); // tambahkan ini
      });
    });
  }

  void _updateSelectedText() {
    if (_mode == null) {
      selectedText = 'Memuat data mode...';
    } else if (_mode == 'otomatis') {
      selectedText =
      'Mode saat ini $_mode, sayuran yang anda pilih adalah ${_plant ?? 'memuat...'} dengan PPM Nutrisi Min (${_tdsMin?.toInt() ?? 'memuat...'}) dan PPM Nutrisi Max (${_tdsMax?.toInt() ?? 'memuat...'})';
    } else if (_mode == 'manual') {
      selectedText = 'Mode saat ini $_mode';
    } else {
      selectedText = 'Mode saat ini tidak diketahui';
    }
  }

  void _showPlantInfoDialog() {
    // Ambil nama sayuran tanpa prefix kalimat agar mudah dicocokkan
    String plantName = (_plant ?? '').toLowerCase();

    String description = '';
    String phRange = '';
    String ppmRange = '';

    // Contoh data info untuk beberapa jenis sayuran
    if (plantName.contains('selada')) {
      description = 'Selada adalah sayuran daun yang mudah tumbuh, cocok untuk hidroponik.';
      phRange = 'pH ideal: 6.0 - 7.0';
      ppmRange = 'PPM nutrisi: 560 - 840';
    } else if (plantName.contains('bayam')) {
      description = 'Bayam kaya akan zat besi dan nutrisi penting, cocok hidroponik.';
      phRange = 'pH ideal: 6.5 - 7.5';
      ppmRange = 'PPM nutrisi: 1000 - 1500';
    } else if (plantName.isEmpty) {
      description = 'Jenis tanaman belum dipilih.';
      phRange = '';
      ppmRange = '';
    } else {
      description = 'Informasi sayuran belum tersedia.';
      phRange = 'pH ideal: N/A';
      ppmRange = 'PPM nutrisi: N/A';
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Tanaman',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                if (phRange.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(phRange, style: GoogleFonts.poppins(color: Colors.white)),
                ],
                if (ppmRange.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(ppmRange, style: GoogleFonts.poppins(color: Colors.white)),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(color: Color(0xFFEAF1B1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF728C5A),
        title: Text(
          displayName != null ? 'Hi, $displayName' : 'Hi, Guest',
          style: GoogleFonts.poppins(
            color: const Color(0xFF102F15),
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset('assets/gif/hidroponik.json'),
                ),
                const SizedBox(width: 8),
                Text(
                  'Selamat datang di Gaul Hidroponik!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAF1B1)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: (_mode == 'manual') ? null : _showPlantInfoDialog,
                    child: const Icon(Icons.info_outline, color: Color(0xFFEAF1B1)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_volumeAir != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAF1B1)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IotMonitoringPage()),
                        );
                      },
                      child: Icon(
                        _volumeAir! < 15 ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                        color: const Color(0xFFEAF1B1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _volumeAir! < 15
                            ? "Volume air kurang, segera isi ulang!"
                            : "Volume air cukup!",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (_mode == 'otomatis' && _plant != null && _tds != null && _tdsMin != null && _tdsMax != null)
              (() {
                if (_tds! < _tdsMin!) {
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAF1B1)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const IotMonitoringPage()),
                            );
                          },
                          child: const Icon(Icons.warning_amber_outlined, color: Color(0xFFEAF1B1)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "PPM nutrisi untuk $_plant kurang, segera tambah nutrisi!",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (_tds! > _tdsMax!) {
                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAF1B1)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const IotMonitoringPage()),
                            );
                          },
                          child: const Icon(Icons.warning_amber_outlined, color: Color(0xFFEAF1B1)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "PPM nutrisi untuk $_plant terlalu tinggi, segera kurangi nutrisi!",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })()
            else if (_mode == 'manual')
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAF1B1)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IotControllingPage()),
                        );
                      },
                      child: const Icon(Icons.info_outline, color: Color(0xFFEAF1B1)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Pilih tanaman untuk pengontrolan otomatis!",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
