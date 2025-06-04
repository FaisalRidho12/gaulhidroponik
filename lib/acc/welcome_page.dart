import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  WelcomePage({required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF728C5A), // ← Warna diubah di sini
              Color(0xFFEBFADC),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      "Welcome",
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
                      "Gaul Hidroponik",
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
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 60),
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: MaterialButton(
                        onPressed: () async {
                          bool? success = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                          if (success == true) onLoginSuccess();
                        },
                        height: 50,
                        minWidth: double.infinity,
                        color: Color(0xFF728C5A), // ← Warna diubah di sini
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1600),
                      child: MaterialButton(
                        onPressed: () async {
                          bool? success = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterPage()),
                          );
                          if (success == true) onLoginSuccess();
                        },
                        height: 50,
                        minWidth: double.infinity,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: Color(0xFF728C5A)), // ← Warna diubah di sini
                        ),
                        child: Text(
                          "Register",
                          style: GoogleFonts.poppins(
                            color: Color(0xFF728C5A), // ← Warna diubah di sini
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
          ],
        ),
      ),
    );
  }
}
