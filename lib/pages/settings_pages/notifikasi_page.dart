import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({Key? key}) : super(key: key);

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  List<String> _targetTimes = [];
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
    _loadTargetTimes();
  }

  Future<List<Map<String, dynamic>>> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifJson = prefs.getString('saved_notifications');
    if (notifJson == null) return [];
    final List<dynamic> notifList = jsonDecode(notifJson);
    return notifList.cast<Map<String, dynamic>>();
  }

  Future<void> _loadTargetTimes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetTimes = prefs.getStringList('target_times') ?? [];
    });
  }

  Future<void> _saveTargetTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('target_times', _targetTimes);
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm:ss').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  Future<void> _addTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formatted = picked.format(context);
      // Format jadi HH:mm (24h)
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final time24 = '$hour:$minute';

      if (!_targetTimes.contains(time24)) {
        setState(() {
          _targetTimes.add(time24);
          _targetTimes.sort();
        });
        await _saveTargetTimes();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade700.withOpacity(0.9),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Waktu notifikasi berhasil ditambahkan!',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
      } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange.shade700.withOpacity(0.9),
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Waktu tersebut sudah ditambahkan sebelumnya.',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
      }
    }
  }

  void _removeTime(String time) async {
    setState(() {
      _targetTimes.remove(time);
    });
    await _saveTargetTimes();
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  bool _isValidTimeFormat(String input) {
    // Validasi format HH:mm dengan regex
    final regExp = RegExp(r'^\d{2}:\d{2}$');
    if (!regExp.hasMatch(input)) return false;

    final parts = input.split(':');
    final hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;

    return hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Jadwal Notifikasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jadwal Notifikasi:',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _addTime(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEAF1B1),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._targetTimes.map((time) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          time,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removeTime(time),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white, height: 32),
            // Riwayat Notifikasi
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Riwayat Notifikasi:',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada notifikasi',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final notifications = snapshot.data!;
                notifications.sort((a, b) {
                  final dtA = DateTime.parse(a['datetime']);
                  final dtB = DateTime.parse(b['datetime']);
                  return dtB.compareTo(dtA);
                });

                return ListView.separated(
                  itemCount: notifications.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final title = notif['title'] ?? 'Tidak ada judul';
                    final message = notif['message'] ?? '';
                    final datetime = notif['datetime'] ?? '';

                    return Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAF1B1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notifications, color: Color(0xFFEAF1B1)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFFEAF1B1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDateTime(datetime),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
