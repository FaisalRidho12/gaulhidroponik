import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class IotControllingPage extends StatefulWidget {
  const IotControllingPage({super.key});

  @override
  State<IotControllingPage> createState() => _IotControllingPageState();
}

class _IotControllingPageState extends State<IotControllingPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('hidroponik/control');
  final DatabaseReference _plantsRef = FirebaseDatabase.instance.ref('hidroponik/jenisTanaman');

  String _mode = '';
  bool _relay1 = false;
  bool _relay2 = false;
  String? _selectedPlant;
  List<String> _availablePlants = [];
  final TextEditingController _newPlantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
    _loadPlants();
  }

  void _listenToFirebase() {
    _dbRef.child('mode').onValue.listen((event) {
      final newMode = event.snapshot.value.toString();
      setState(() => _mode = newMode);
    });

    _dbRef.child('relay1').onValue.listen((event) {
      setState(() => _relay1 = event.snapshot.value == 'ON');
    });

    _dbRef.child('relay2').onValue.listen((event) {
      setState(() => _relay2 = event.snapshot.value == 'ON');
    });

    _dbRef.child('selectedPlant').onValue.listen((event) {
      if (mounted) {
        setState(() {
          _selectedPlant = event.snapshot.exists && event.snapshot.value != null
              ? event.snapshot.value.toString()
              : null;
        });
      }
    });
  }

  Future<void> _updateMode(String newMode) async {
    await _dbRef.child('mode').set(newMode);

    // Kosongkan selectedPlant saat:
    // - Beralih ke otomatis (seperti sebelumnya)
    // - ATAU beralih ke manual (tambahan baru)
    if (newMode == 'otomatis' || newMode == 'manual') {
      await _dbRef.child('selectedPlant').set(''); // Kosongkan di Firebase
      if (mounted) {
        setState(() => _selectedPlant = null); // Kosongkan di state lokal
      }
    }
  }

  Future<void> _updateRelayState(int relayNumber, bool isOn) async {
    final path = relayNumber == 1 ? 'relay1' : 'relay2';
    await _dbRef.child(path).set(isOn ? 'ON' : 'OFF');
  }

  void _loadPlants() {
    _plantsRef.onValue.listen((event) async {
      if (mounted) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        final availablePlants = data?.keys.cast<String>().toList() ?? [];

        // Jika selectedPlant tidak ada di daftar baru, kosongkan
        if (_selectedPlant != null && !availablePlants.contains(_selectedPlant)) {
          await _dbRef.child('selectedPlant').set(''); // Update Firebase
          setState(() => _selectedPlant = null); // Update state lokal
        }

        setState(() => _availablePlants = availablePlants);
      }
    });
  }

  void _addNewPlant() {
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tambah Tanaman Baru',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPlantController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: const Color(0xFFEAF1B1),
                    decoration: InputDecoration(
                      hintText: 'Nama tanaman',
                      hintStyle: GoogleFonts.poppins(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF1B1)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Masukkan nama tanaman';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(color: const Color(0xFFEAF1B1)),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAF1B1),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final plantName = _newPlantController.text.trim().toLowerCase();
                            await _plantsRef.child(plantName).set({
                              'tds_min': 0,
                              'tds_max': 0,
                            });
                            
                            _newPlantController.clear();
                            Navigator.pop(context); // Tutup dialog tambah tanaman

                            // Tampilkan dialog konfirmasi
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFEAF1B1)),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Sukses!',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Tanaman "$plantName" berhasil ditambahkan. Edit nilai PPM sekarang?',
                                          style: GoogleFonts.poppins(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(
                                                'Nanti',
                                                style: GoogleFonts.poppins(color: const Color(0xFFEAF1B1)),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFEAF1B1),
                                                foregroundColor: Colors.black,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context); // Tutup dialog konfirmasi
                                                _showEditPpmDialog(plantName); // Buka dialog edit PPM
                                              },
                                              child: Text('Edit Sekarang', style: GoogleFonts.poppins()),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Text('Simpan', style: GoogleFonts.poppins()),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateSelectedPlant(String? newValue) {
    if (newValue != null) {
      _dbRef.child('selectedPlant').set(newValue);
    }
  }

  void _showEditPpmDialog(String plantName) async {
    final ppmRef = _plantsRef.child('$plantName/');
    DataSnapshot snapshot = await ppmRef.get();
    Map<dynamic, dynamic>? values = snapshot.value as Map?;

    String tdsMin = values?['tds_min']?.toString() ?? '';
    String tdsMax = values?['tds_max']?.toString() ?? '';

    final _formKey = GlobalKey<FormState>();
    TextEditingController minController = TextEditingController(text: tdsMin);
    TextEditingController maxController = TextEditingController(text: tdsMax);

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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Nilai PPM untuk $plantName',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: minController,
                    keyboardType: TextInputType.number,
                    cursorColor: Color(0xFFEAF1B1),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'PPM Minimum',
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Isi PPM minimum';
                      if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    cursorColor: Color(0xFFEAF1B1),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'PPM Maksimum',
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Isi PPM maksimum';
                      if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                      if (int.parse(value) <= int.parse(minController.text)) {
                        return 'PPM max harus > PPM min';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(color: Color(0xFFEAF1B1)),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAF1B1),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await ppmRef.update({
                              'tds_min': int.parse(minController.text),
                              'tds_max': int.parse(maxController.text),
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Simpan', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deletePlant(String plantName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hapus Tanaman',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Yakin ingin menghapus tanaman "$plantName"?',
                  style: GoogleFonts.poppins(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(color: const Color(0xFFEAF1B1)),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await _plantsRef.child(plantName).remove();
                        if (_selectedPlant == plantName) {
                          await _dbRef.child('selectedPlant').set('');
                          setState(() => _selectedPlant = null);
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Hapus', style: GoogleFonts.poppins()),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManual = _mode == 'manual';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102F15)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'IoT Controlling',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEBFADC), width: 2),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        'Mode Kontrol Nutrisi',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ToggleButtons(
                      isSelected: [_mode == 'otomatis', _mode == 'manual'],
                      onPressed: (index) {
                        final selectedMode = index == 0 ? 'otomatis' : 'manual';
                        _updateMode(selectedMode);
                      },
                      color: Colors.white,
                      selectedColor: Colors.black,
                      fillColor: const Color(0xFFEAF1B1),
                      borderRadius: BorderRadius.circular(10),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Otomatis',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Manual',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isManual) ...[
                    _buildRelaySwitchTile('Nutrisi A', _relay1, 1),
                    const SizedBox(height: 5),
                    _buildRelaySwitchTile('Nutrisi B', _relay2, 2),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAF1B1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFEAF1B1),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Pilih jenis tanaman atau tambah, edit, dan hapus tanaman!",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (!isManual)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<String>(
                            isExpanded: true,
                            value: _availablePlants.contains(_selectedPlant) ? _selectedPlant : null,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              border: InputBorder.none,
                            ),
                            hint: Text(
                              _availablePlants.isEmpty
                                  ? 'Tanaman tidak tersesia'
                                  : 'Pilih jenis tanaman',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            items: _availablePlants
                                .toSet() // Hindari duplikat
                                .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item[0].toUpperCase() + item.substring(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ))
                                .toList(),
                            onChanged: _availablePlants.isEmpty
                                ? null // Nonaktifkan jika tidak ada tanaman
                                : (newValue) {
                              if (newValue != null) {
                                _updateSelectedPlant(newValue);
                              }
                            },
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFFEAF1B1)),
                          onPressed: _addNewPlant,
                        ),
                        if (_selectedPlant != null) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFEAF1B1)),
                            onPressed: () => _showEditPpmDialog(_selectedPlant!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Color(0xFFEAF1B1)),
                            onPressed: () => _deletePlant(_selectedPlant!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRelaySwitchTile(String title, bool value, int relayNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SwitchListTile(
          title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
          secondary: const Icon(Icons.water_drop, color: Color(0xFFEAF1B1)),
          value: value,
          onChanged: (val) => _updateRelayState(relayNumber, val),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Colors.transparent,
          activeColor: Colors.black,
          activeTrackColor: const Color(0xFFEAF1B1),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}
