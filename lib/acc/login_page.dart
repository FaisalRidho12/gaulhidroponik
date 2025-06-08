import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaulhidroponik/acc/register_page.dart';
import 'package:gaulhidroponik/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

void _showCustomSnackBar(String message, {bool isError = false}) {
  final backgroundColor = isError ? Colors.red.shade400 : Color(0xFF728C5A);
  final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      duration: Duration(seconds: 3),
    ),
  );
}


  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      _showCustomSnackBar('Login berhasil');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      String message = 'Login gagal';
      if (e.code == 'user-not-found') {
        message = 'Pengguna tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }

      _showCustomSnackBar(message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF728C5A), // ← diubah
              Color(0xFFEBFADC), // ← diubah
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      "Welcome Back",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  FadeInDown(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Silakan masuk ke akun Anda",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FadeInUp(
                        duration: Duration(milliseconds: 1400),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          cursorColor: Color(0xFF728C5A),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: GoogleFonts.poppins(),
                            floatingLabelStyle: GoogleFonts.poppins(
                              color: Color(0xFF728C5A),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade800),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF728C5A),
                                  width: 2), // ← diubah
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeInUp(
                        duration: Duration(milliseconds: 1600),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          enabled: !_isLoading,
                          cursorColor: Color(0xFF728C5A),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: GoogleFonts.poppins(),
                            floatingLabelStyle: GoogleFonts.poppins(
                              color: Color(0xFF728C5A),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade800),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Color(0xFF728C5A),
                                  width: 2), // ← diubah
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      FadeInUp(
                        duration: Duration(milliseconds: 1700),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Belum punya akun? ",
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: "Daftar",
                                  style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      FadeInUp(
                        duration: Duration(milliseconds: 1800),
                        child: MaterialButton(
                          onPressed: _isLoading ? null : _login,
                          height: 50,
                          minWidth: double.infinity,
                          color: Color(0xFF728C5A), // ← diubah
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
