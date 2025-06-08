import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EditAkunPage extends StatefulWidget {
  @override
  State<EditAkunPage> createState() => _EditAkunPageState();
}

class _EditAkunPageState extends State<EditAkunPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> avatarAssets = [
    'assets/profiles/1.png',
    'assets/profiles/2.png',
    'assets/profiles/3.png',
    'assets/profiles/4.png',
  ];

  String? selectedAvatarAsset;

 void showCustomSnackBar(String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      backgroundColor: isError ? Colors.red[400] :Color.fromARGB(255, 103, 152, 111),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}


  @override
  void initState() {
    super.initState();
    _loadProfileImage();
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
        showCustomSnackBar('Foto profil berhasil diperbarui');
      }
    } catch (e) {
      showCustomSnackBar('Gagal memperbarui foto profil', isError: true);
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('user_profile_image');
    setState(() {
      selectedAvatarAsset = savedPath ?? _auth.currentUser?.photoURL;
    });
  }

Future<void> _pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    // Upload gambar ke Firebase Storage (jika diperlukan)
    // Atau langsung simpan path file lokal ke Firebase Auth (tidak direkomendasikan untuk production)
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Simpan path file ke photoURL (ini hanya contoh, untuk production sebaiknya upload ke storage)
        await user.updatePhotoURL(pickedFile.path);
        await user.reload();
        
        // Juga simpan ke SharedPreferences untuk cache lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_image', pickedFile.path);
        
        setState(() {
          selectedAvatarAsset = pickedFile.path;
        });
        
        showCustomSnackBar('Foto profil berhasil diperbarui');
      }
    } catch (e) {
      showCustomSnackBar('Gagal memperbarui foto profil', isError: true);
    }
  }
}


void _showAvatarSelectionSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        color: const Color(0xFF728C5A),
        padding: EdgeInsets.all(16),
        height: 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // List avatar di kiri
            Expanded(
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
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('user_profile_image');
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
            ),
            const SizedBox(width: 16),
            // Tombol upload bulat
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromGallery();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.upload,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
                  cursorColor: Color.fromARGB(255, 250, 255, 245),
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
                          showCustomSnackBar('Username tidak boleh kosong', isError: true);
                          return;
                        }
                        try {
                          await user?.updateDisplayName(newUsername);
                          await user?.reload();
                          setState(() {}); // Refresh UI
                          Navigator.pop(context);
                          showCustomSnackBar('Username berhasil diperbarui');
                        } catch (e) {
                          showCustomSnackBar('Gagal memperbarui Username', isError: true);
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
                  cursorColor: Color.fromARGB(255, 250, 255, 245),
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
                  cursorColor: Color.fromARGB(255, 250, 255, 245),
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
                          showCustomSnackBar('Harap isi semua kolom', isError: true);
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
                          showCustomSnackBar('Password berhasil diperbarui');

                        } on FirebaseAuthException catch (e) {
                          String message = 'Terjadi kesalahan';
                          if (e.code == 'wrong-password') {
                            message = 'Password lama salah';
                          } else if (e.code == 'weak-password') {
                            message = 'Password baru terlalu lemah';
                          }
                          showCustomSnackBar(message, isError: true);
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
                          ? (selectedAvatarAsset!.startsWith('assets/')
                              ? AssetImage(selectedAvatarAsset!) as ImageProvider
                              : FileImage(File(selectedAvatarAsset!)))
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
