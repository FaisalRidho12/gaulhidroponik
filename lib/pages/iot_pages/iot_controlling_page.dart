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

  String _mode = ''; // default
  bool _relay1 = false;
  bool _relay2 = false;

  // Untuk dropdown jenis tanaman (otomatis mode)
  String? _selectedCategory;
  final List<String> _categories = ['selada', 'bayam'];

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
    _loadSelectedCategory();
    _setupCategoryListener();
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
  }

  Future<void> _updateMode(String newMode) async {
    await _dbRef.child('mode').set(newMode);
  }

  Future<void> _updateRelayState(int relayNumber, bool isOn) async {
    final path = relayNumber == 1 ? 'relay1' : 'relay2';
    await _dbRef.child(path).set(isOn ? 'ON' : 'OFF');
  }

  // ---- Bagian untuk jenis tanaman (otomatis) ----

  bool _isValidCategory(String? category) {
    return category != null && _categories.contains(category);
  }

  void _loadSelectedCategory() async {
    DataSnapshot snapshot = await FirebaseDatabase.instance.ref('hidroponik/jenisTanaman/nama').get();
    if (snapshot.exists) {
      final value = snapshot.value.toString();
      if (_isValidCategory(value)) {
        setState(() {
          _selectedCategory = value;
        });
      }
    }
  }

  void _setupCategoryListener() {
    FirebaseDatabase.instance.ref('hidroponik/jenisTanaman/nama').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final value = event.snapshot.value.toString();
        setState(() {
          if (_isValidCategory(value)) {
            _selectedCategory = value;
          } else {
            _selectedCategory = null;  // Reset dropdown jika value tidak valid atau kosong
          }
        });
      } else if (mounted) {
        setState(() {
          _selectedCategory = null; // Reset jika data tidak ada di Firebase
        });
      }
    });
  }

  void _updateCategory(String? newValue) {
    if (newValue != null) {
      FirebaseDatabase.instance.ref('hidroponik/jenisTanaman/nama').set(newValue);
    }
  }

  void _showEditPpmDialog() async {
    final DatabaseReference tdsMinRef = FirebaseDatabase.instance.ref('hidroponik/jenisTanaman/tds_min');
    final DatabaseReference tdsMaxRef = FirebaseDatabase.instance.ref('hidroponik/jenisTanaman/tds_max');

    // Ambil data awal
    DataSnapshot minSnapshot = await tdsMinRef.get();
    DataSnapshot maxSnapshot = await tdsMaxRef.get();

    String tdsMin = minSnapshot.exists ? minSnapshot.value.toString() : '';
    String tdsMax = maxSnapshot.exists ? maxSnapshot.value.toString() : '';

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
                    'Edit Nilai PPM',
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'PPM Minimum',
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),  // lebih tebal dan putih solid
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Isi PPM minimum';
                      if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'PPM Maksimum',
                      labelStyle: GoogleFonts.poppins(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),  // lebih tebal dan putih solid
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Isi PPM maksimum';
                      if (double.tryParse(value) == null) return 'Masukkan angka yang valid';
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
                            final int minVal = int.parse(minController.text);
                            final int maxVal = int.parse(maxController.text);

                            await tdsMinRef.set(minVal);
                            await tdsMaxRef.set(maxVal);

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
                color: Colors.white.withOpacity(0.1), // optional, supaya backgroundnya ada
              ),
              padding: const EdgeInsets.all(16), // kasih padding biar isinya ga nempel ke border
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
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField2<String>(
                              isExpanded: true,
                              value: _isValidCategory(_selectedCategory) ? _selectedCategory : null,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                border: InputBorder.none,
                              ),
                              hint: Text(
                                'Pilih jenis tanaman',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              items: _categories
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
                              onChanged: _updateCategory,
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFEAF1B1)),
                            onPressed: () => _showEditPpmDialog(),
                          ),
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