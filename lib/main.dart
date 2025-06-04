import 'package:flutter/material.dart';
import 'package:gaulhidroponik/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'splash_screen.dart';

import 'acc/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/iot_page.dart';
import 'pages/settings_page.dart';

import 'services/notification_service.dart';
import 'services/firebase_listener_service.dart';

// Global navigator key supaya bisa navigasi dari luar widget
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaul Hidroponik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
    );
  }
}

// Widget untuk cek status login user
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User sudah login
      return MyHomePage();
    } else {
      // User belum login
      return WelcomePage(
        onLoginSuccess: () {
          Navigator.of(navigatorKey.currentContext!).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        },
      );
    }
  }
}

// Halaman utama setelah login/register
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final FirebaseListenerService _listenerService = FirebaseListenerService();

  final _pageOptions = [
    HomePage(),
    IotPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _listenerService.startListening();
  }

  @override
  void dispose() {
    _listenerService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color(0xFF728C5A),
        color: Color(0xFFEBFADC),
        buttonBackgroundColor: Color(0xFFEBFADC),
        height: 60.0,
        index: _selectedIndex,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Color(0xFF102F15)),
          Icon(Icons.devices, size: 30, color: Color(0xFF102F15)),
          Icon(Icons.settings, size: 30, color: Color(0xFF102F15)),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
