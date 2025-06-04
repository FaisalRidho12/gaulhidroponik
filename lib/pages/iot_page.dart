import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'iot_pages/iot_monitoring_page.dart';
import 'iot_pages/iot_controlling_page.dart';

class IotPage extends StatefulWidget {
  const IotPage({super.key});

  @override
  State<IotPage> createState() => _IotPageState();
}

class _IotPageState extends State<IotPage> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Trigger animasi ketika halaman ditampilkan
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'IoT Monitoring & Controlling',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: AnimatedSlide(
            offset: _visible ? Offset.zero : const Offset(0, 0.1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Hero(
                  tag: 'iot-icon',
                  child: Icon(
                    Icons.devices_other_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Kontrol dan Monitoring Sistem Hidroponik',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEAF1B1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pantau dan kendalikan perangkat IoT Anda secara langsung.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureButton(
                      context,
                      icon: Icons.monitor_heart_rounded,
                      iconColor: Color(0xFF728C5A),
                      label: 'Monitoring',
                      heroTag: 'monitor',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IotMonitoringPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildFeatureButton(
                      context,
                      icon: Icons.settings_remote_rounded,
                      iconColor: Color(0xFF728C5A),
                      label: 'Controlling',
                      heroTag: 'control',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IotControllingPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required String heroTag,
    Color iconColor = const Color(0xFF728C5A),
  }) {
    return Hero(
      tag: heroTag,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF728C5A),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: Colors.black45,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
