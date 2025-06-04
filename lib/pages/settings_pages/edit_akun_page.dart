import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAkunPage extends StatefulWidget {
  @override
  State<EditAkunPage> createState() => _EditAkunPageState();
}

class _EditAkunPageState extends State<EditAkunPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> avatarAssets = [
    'assets/profiles/andika1.jpg',
    'assets/profiles/andika2.jpg',
    'assets/profiles/andika3.jpg',
  ];

  String? selectedAvatarAsset;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    selectedAvatarAsset = user?.photoURL;
  }

  Future<void> _updateUserPhoto(String assetPath) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(assetPath);
        await user.reload();
        setState(() {
          selectedAvatarAsset = assetPath;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui foto profil')),
      );
    }
  }

  void _showAvatarSelectionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: const Color(0xFF728C5A),
          padding: EdgeInsets.all(16),
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: avatarAssets.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final assetPath = avatarAssets[index];
              final isSelected = assetPath == selectedAvatarAsset;
              return GestureDetector(
                onTap: () async {
                  await _updateUserPhoto(assetPath);
                  Navigator.pop(context, true);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(assetPath),
                    ),
                    if (isSelected)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditUsernameDialog() {
    final user = _auth.currentUser;
    final usernameController = TextEditingController(text: user?.displayName ?? '');

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
                  'Edit Username',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: usernameController,
                  cursorColor: Color(0xFF728C5A),
                  decoration: InputDecoration(
                    labelText: 'Username Baru',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),  // lebih tebal dan putih solid
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),  // kuning muda tebal saat fokus
                    ),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal', style: TextStyle(color: Color(0xFFEAF1B1))),
                    ),
                    TextButton(
                      onPressed: () async {
                        final newUsername = usernameController.text.trim();
                        if (newUsername.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Username tidak boleh kosong')),
                          );
                          return;
                        }
                        try {
                          await user?.updateDisplayName(newUsername);
                          await user?.reload();
                          setState(() {}); // Refresh UI
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Username berhasil diperbarui')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal memperbarui username')),
                          );
                        }
                      },
                      child: Text('Simpan', style: TextStyle(color: Color(0xFFEAF1B1))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final user = _auth.currentUser;

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
                  'Ganti Password',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  cursorColor: Color(0xFF728C5A),
                  decoration: InputDecoration(
                    labelText: 'Password Lama',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),  // lebih tebal dan putih solid
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),
                    ),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  cursorColor: Color(0xFF728C5A),
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),  // lebih tebal dan putih solid
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEAF1B1), width: 2.0),
                    ),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal', style: TextStyle(color: Color(0xFFEAF1B1))),
                    ),
                    TextButton(
                      onPressed: () async {
                        final oldPassword = oldPasswordController.text.trim();
                        final newPassword = newPasswordController.text.trim();

                        if (oldPassword.isEmpty || newPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Harap isi semua kolom')),
                          );
                          return;
                        }

                        try {
                          final cred = EmailAuthProvider.credential(
                            email: user!.email!,
                            password: oldPassword,
                          );
                          await user.reauthenticateWithCredential(cred);
                          await user.updatePassword(newPassword);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password berhasil diubah')),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message = 'Terjadi kesalahan';
                          if (e.code == 'wrong-password') {
                            message = 'Password lama salah';
                          } else if (e.code == 'weak-password') {
                            message = 'Password baru terlalu lemah';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                      child: Text('Ubah', style: TextStyle(color: Color(0xFFEAF1B1))),
                    ),
                  ],
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
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Akun',
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
          if (user != null) ...[
            Center(
              child: GestureDetector(
                onTap: _showAvatarSelectionSheet,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.4),
                      backgroundImage: selectedAvatarAsset != null
                          ? AssetImage(selectedAvatarAsset!)
                          : null,
                      child: selectedAvatarAsset == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // background putih supaya icon jelas
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF728C5A), width: 2),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: Color(0xFF102F15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAF1B1)),
              ),
              child: ListTile(
                leading: Icon(Icons.person, color: Color(0xFF102F15)),
                title: Text(
                  'Username: ${user.displayName ?? "Tidak tersedia"}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                trailing: Icon(Icons.edit, color: Color(0xFFEAF1B1)),
                onTap: _showEditUsernameDialog,
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
                leading: Icon(Icons.email, color: Color(0xFF102F15)),
                title: Text(
                  'Email: ${user.email}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ),
          ],
          Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAF1B1)),
            ),
            child: ListTile(
              leading: Icon(Icons.lock, color: Color(0xFF102F15)),
              title: Text(
                'Ganti Password',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: Icon(Icons.edit, color: Color(0xFFEAF1B1)),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
