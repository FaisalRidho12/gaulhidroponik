import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaulhidroponik/acc/welcome_page.dart';
import 'package:gaulhidroponik/main.dart';
import 'settings_pages/edit_akun_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    // Pasang listener userChanges agar UI update otomatis jika user berubah (misal foto profile)
    _auth.userChanges().listen((updatedUser) {
      setState(() {
        user = updatedUser;
      });
    });
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _auth.signOut();
      Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WelcomePage(onLoginSuccess: () {
            Navigator.of(navigatorKey.currentContext!).pushReplacement(
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }),
        ),
            (route) => false,
      );
    }
  }

  void _deleteAccount(BuildContext context) {
    final passwordController = TextEditingController();
    final user = _auth.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Akun'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Masukkan password untuk konfirmasi.'),
              SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text.trim();

                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password harus diisi')),
                  );
                  return;
                }

                try {
                  final cred = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: password,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.delete();

                  Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => WelcomePage(onLoginSuccess: () {}),
                    ),
                        (route) => false,
                  );

                  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
                      SnackBar(content: Text('Akun berhasil dihapus')));
                } on FirebaseAuthException catch (e) {
                  String message = 'Terjadi kesalahan saat menghapus akun.';
                  if (e.code == 'wrong-password') {
                    message = 'Password salah.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserAvatar(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      // Jika tidak ada foto profil, tampilkan icon default
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white.withOpacity(0.4),
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.grey[700],
        ),
      );
    } else if (photoUrl.startsWith('http')) {
      // Jika photoUrl berupa URL jaringan (misal Google profile photo)
      return CircleAvatar(
        radius: 80,
        backgroundColor: Colors.white.withOpacity(0.4),
        backgroundImage: NetworkImage(photoUrl),
      );
    } else {
      // Jika photoUrl diasumsikan path asset lokal
      return CircleAvatar(
        radius: 80,
        backgroundColor: Colors.white.withOpacity(0.4),
        backgroundImage: AssetImage(photoUrl),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                _buildUserAvatar(photoUrl),
                SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'No Username',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user?.email ?? 'No Email',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: ListTile(
              leading: Icon(Icons.edit, color: Color(0xFF102F15)),
              title: Text(
                'Edit Akun',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditAkunPage()),
                );
              },
            ),
          ),
          Divider(color: Colors.white70),
          Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: Color(0xFF102F15)),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () => _logout(context),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Color(0xFF102F15)),
              title: Text(
                'Hapus Akun',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () => _deleteAccount(context),
            ),
          ),
        ],
      ),
    );
  }
}
