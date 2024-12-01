import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/community_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/setting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  runApp(MyApp());
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens
  final List<Widget> _pages = [
    HomeScreen(),
    LocationScreen(),
    CommunityScreen(),
    ContactScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SecureShe",
          style: TextStyle(
            color:
                Colors.white, // Change text color to white for better contrast
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFFF007F),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFFFF007F),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Helper method for dynamic page title
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Location';
      case 2:
        return 'Community';
      case 3:
        return 'Contact';
      case 4:
        return 'Settings';
      default:
        return '';
    }
  }
}
