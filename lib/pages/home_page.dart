import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:gaulhidroponik/pages/iot_pages/iot_monitoring_page.dart';
import 'package:gaulhidroponik/pages/iot_pages/iot_controlling_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> plants = ['Bayam', 'Selada', 'Sawi', 'Kangkung', 'Pakcoy', 'Kale'];
  String? displayName;
  String selectedText = 'Memuat data...';

  final DatabaseReference _plantRef = FirebaseDatabase.instance.ref("/hidroponik/control/selectedPlant");
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

  int _manualIndex = 0;
  PageController _pageController = PageController();
  Timer? _autoSlideTimer;



  @override
void initState() {
  super.initState();

  _startAutoSlideIfManual();

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    displayName = user.displayName ?? user.email;
  }
  
  // Listen mode
  _modeRef.onValue.listen((event) {
    final modeValue = event.snapshot.value;
    setState(() {
      _mode = (modeValue is String && modeValue.isNotEmpty) ? modeValue.toLowerCase() : null;
      _updateSelectedText(); // Panggil update text saat mode berubah
    });
    _startAutoSlideIfManual();
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
      _updateSelectedText(); // Panggil update text saat tanaman berubah
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

  void _startAutoSlideIfManual() {
    if (_mode == "manual") {
      _autoSlideTimer?.cancel();
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          int nextPlantIndex = (_manualIndex + 1) % plants.length;
          _pageController.animateToPage(
            nextPlantIndex,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
          setState(() {
            _manualIndex = nextPlantIndex;
            _plant = plants[nextPlantIndex]; // Update tanaman yang ditampilkan
          });
        }
      });
    } else {
      _autoSlideTimer?.cancel();
    }
  }


  void _updateSelectedText() async {
  if (_mode == null) {
    selectedText = 'Memuat data mode...';
  } else if (_mode == 'otomatis') {
    if (_plant != null) {
      try {
        // Ambil data PPM untuk tanaman yang dipilih
        final plantName = _plant!.toLowerCase();
        final snapshot = await FirebaseDatabase.instance
            .ref('hidroponik/jenisTanaman/$plantName')
            .once();

        if (snapshot.snapshot.value != null) {
          final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
          final tdsMin = data['tds_min']?.toString() ?? 'belum diatur';
          final tdsMax = data['tds_max']?.toString() ?? 'belum diatur';

          setState(() {
            selectedText = 'Mode saat ini $_mode, sayuran yang anda pilih adalah $_plant '
                'dengan PPM Nutrisi Min ($tdsMin) '
                'dan PPM Nutrisi Max ($tdsMax)';
          });
        } else {
          setState(() {
            selectedText = 'Mode saat ini $_mode, sayuran yang anda pilih adalah $_plant '
                '(nilai PPM belum diatur)';
          });
        }
      } catch (e) {
        setState(() {
          selectedText = 'Mode saat ini $_mode, sayuran yang anda pilih adalah $_plant '
              '(gagal memuat data PPM)';
        });
      }
    } else {
      selectedText = 'Mode saat ini $_mode, belum memilih tanaman';
    }
  } else if (_mode == 'manual') {
    selectedText = 'Mode saat ini $_mode';
  } else {
    selectedText = 'Mode saat ini tidak diketahui';
  }
}

  void _showPlantInfoDialog(String plantName) async {
  // Ambil data tanaman dari Firebase
  final plantData = await FirebaseDatabase.instance
      .ref('hidroponik/jenisTanaman/${plantName.toLowerCase()}')
      .once();

  final data = plantData.snapshot.value as Map<dynamic, dynamic>?;
  
  String description = '';
  String phRange = '';
  String ppmRange = '';

  // Set deskripsi berdasarkan jenis tanaman
  if (plantName.toLowerCase().contains('selada')) {
  description = 'Selada adalah sayuran daun yang mudah tumbuh, cocok untuk hidroponik.';
  phRange = 'pH ideal: 6.0 - 7.0';
} else if (plantName.toLowerCase().contains('bayam')) {
  description = 'Bayam kaya akan zat besi dan nutrisi penting, cocok untuk hidroponik.';
  phRange = 'pH ideal: 6.5 - 7.5';
} else if (plantName.toLowerCase().contains('sawi')) {
  description = 'Sawi adalah sayuran daun yang cepat tumbuh dan tahan terhadap berbagai kondisi.';
  phRange = 'pH ideal: 6.0 - 7.0';
} else if (plantName.toLowerCase().contains('kangkung')) {
  description = 'Kangkung tumbuh sangat cepat dalam sistem hidroponik dan kaya akan vitamin A dan C.';
  phRange = 'pH ideal: 5.5 - 6.5';
} else if (plantName.toLowerCase().contains('pakcoy')) {
  description = 'Pakcoy atau bok choy adalah sayuran asia yang kaya kalsium dan vitamin K.';
  phRange = 'pH ideal: 6.0 - 7.0';
} else if (plantName.toLowerCase().contains('kale')) {
  description = 'Kale adalah superfood yang sangat bergizi dan tumbuh baik dalam sistem hidroponik.';
  phRange = 'pH ideal: 5.5 - 6.5';
} else {
  description = 'Informasi sayuran belum tersedia.';
  phRange = 'pH ideal: N/A';
}

  // Ambil nilai PPM dari Firebase (jika ada)
  if (data != null) {
    final tdsMin = data['tds_min']?.toString() ?? 'N/A';
    final tdsMax = data['tds_max']?.toString() ?? 'N/A';
    ppmRange = 'PPM nutrisi: $tdsMin - $tdsMax';
  } else {
    ppmRange = 'PPM nutrisi: Belum diatur';
  }

if (data != null) {
  final tdsMin = int.tryParse(data['tds_min']?.toString() ?? '0') ?? 0;
  final tdsMax = int.tryParse(data['tds_max']?.toString() ?? '0') ?? 0;
  
  if (tdsMin <= 0 || tdsMax <= 0 || tdsMax <= tdsMin) {
    ppmRange = '⚠ PPM belum diatur dengan benar';
  } else {
    ppmRange = 'PPM nutrisi: $tdsMin - $tdsMax';
  }
} else {
  ppmRange = 'PPM nutrisi: Belum diatur';
}

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF728C5A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEAF1B1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi $plantName',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 8),
              Text(phRange, style: GoogleFonts.poppins(color: Colors.white)),
              const SizedBox(height: 4),
              Text(ppmRange, style: GoogleFonts.poppins(color: Colors.white)),
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
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEAF1B1)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Informasi tanaman',
                            style: TextStyle(
                              color: Color(0xFFEAF1B1),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () {
                              if (_plant != null) {
                                _showPlantInfoDialog(_plant!);
                              }
                            },
                            child: const Icon(
                              Icons.info_outline,
                              color: Color(0xFFEAF1B1),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _plant ?? 'Memuat...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 150,
                          child: _mode == "manual"
                              ? PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _manualIndex = index;
                                _plant = plants[index]; // Ubah nama tanaman saat slide
                              });
                            },
                            children: plants.map((plant) {
                              return Image.asset(
                                'assets/icons/${plant.toLowerCase()}.png',
                                height: 200,
                                width: 200,
                                fit: BoxFit.contain,
                              );
                            }).toList(),
                          )
                              : (_plant != null
                              ? Image.asset(
                          'assets/icons/${_plant!.toLowerCase()}.png',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.help_outline, size: 50, color: Colors.white);
        },
      )
    : const Center(child: CircularProgressIndicator()))
                        ),
                      ),
                    ],
                  ),
                ),
                // Dot indikator yang diposisikan di tengah bawah container
                if (_mode == "manual")
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8, // Sesuaikan jarak dari bawah
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(plants.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _manualIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                          );
                        }),
                      ),
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
                        _volumeAir! < 16 ? Icons.warning_amber_outlined : Icons.check_circle_outline,
                        color: const Color(0xFFEAF1B1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _volumeAir! < 16
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
