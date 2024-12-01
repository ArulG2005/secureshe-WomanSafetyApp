import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'package:volume_watcher/volume_watcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedOption = 'Basic Level Production';
  List<Map<String, String>> trustedContacts = [];
  final Telephony telephony = Telephony.instance;
  final FlutterTts flutterTts = FlutterTts();
  Timer? _locationTimer;
  int _volumePressCount = 0;
  Timer? _pressResetTimer;
  late Function(double) _volumeListener;
  int currentCallIndex = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _loadSelectedOption();
    _loadTrustedContacts();
    _startVolumeListener();
    _startFirestorePolling();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _pressResetTimer?.cancel();
    VolumeWatcher.removeListener(_volumeListener as int?);
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndRequestPermissions() async {
    if (!await Permission.sms.isGranted) {
      await Permission.sms.request();
    }

    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }

    if (!await Permission.phone.isGranted) {
      await Permission.phone.request();
    }
  }

  void _loadSelectedOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption =
          prefs.getString('selectedOption') ?? 'Basic Level Production';
    });
  }

  void _loadTrustedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? contactStrings = prefs.getStringList('trustedContacts');
    if (contactStrings != null) {
      setState(() {
        trustedContacts = contactStrings.map((contactString) {
          final parts = contactString.split(': ');
          return {'name': parts[0], 'phone': parts[1]};
        }).toList();
      });
    }
  }

  Future<void> _addTrustedContact(String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      trustedContacts.add({'name': name, 'phone': phone});
      List<String> contactStrings = trustedContacts
          .map((contact) => "${contact['name']}: ${contact['phone']}")
          .toList();
      prefs.setStringList('trustedContacts', contactStrings);
    });
  }

  Future<void> _sendLiveLocation() async {
    if (trustedContacts.isEmpty) {
      print("No trusted contacts set.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String message =
          "I am in need of help. My current location is: https://maps.google.com/?q=${position.latitude},${position.longitude}";

      for (var contact in trustedContacts) {
        String phone = contact['phone']!;
        await telephony.sendSms(
          to: phone,
          message: message,
          statusListener: (SendStatus status) {
            if (status == SendStatus.SENT) {
              print("SMS Sent to $phone");
            } else {
              print("SMS Failed to $phone");
            }
          },
        );
      }
    } catch (e) {
      print("Error sending SMS: $e");
    }
  }

  void _startVolumeListener() {
    _volumeListener = (double volume) {
      _onVolumeButtonPressed();
    };

    VolumeWatcher.addListener(_volumeListener);
  }

  void _onVolumeButtonPressed() {
    _volumePressCount++;

    if (_volumePressCount == 3) {
      _sendLiveLocation();
      _startCallingContacts();
      _resetVolumePressCount();
    } else {
      _pressResetTimer?.cancel();
      _pressResetTimer = Timer(Duration(seconds: 2), _resetVolumePressCount);
    }
  }

  void _resetVolumePressCount() {
    _volumePressCount = 0;
    _pressResetTimer?.cancel();
  }

  Future<void> _startCallingContacts() async {
    if (trustedContacts.isEmpty) {
      print("No trusted contacts to call.");
      return;
    }

    currentCallIndex = 0;
    _makeNextCall();
  }

  Future<void> _makeNextCall() async {
    if (currentCallIndex >= trustedContacts.length) {
      print("All contacts called.");
      return;
    }

    final contact = trustedContacts[currentCallIndex];
    final phone = contact['phone']!;

    if (await Permission.phone.isGranted) {
      bool callSuccess =
          (await FlutterPhoneDirectCaller.callNumber(phone)) ?? false;

      if (callSuccess) {
        print('Calling $phone');

        await Future.delayed(Duration(seconds: 5));

        await _speakTtsMessage();

        currentCallIndex++;
        _makeNextCall();
      } else {
        print('Could not launch dialer.');
      }
    } else {
      print('CALL_PHONE permission not granted.');
    }
  }

  Future<void> _speakTtsMessage() async {
    String message = "Help me! I need assistance.";

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(message);
  }

  Future<void> _startFirestorePolling() async {
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        final DocumentSnapshot documentSnapshot = await FirebaseFirestore
            .instance
            .collection('events')
            .doc(
                'events~2Fv_shape_trigger') // Replace with the document ID you're monitoring
            .get();

        if (documentSnapshot.exists) {
          final Map<String, dynamic>? data =
              documentSnapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            print('Firestore data: $data');

            if (data['event'] == 'v_shape_detected') {
              await _sendLiveLocation();
              await _startCallingContacts();
            }
          }
        } else {
          print('No document found');
        }
      } catch (e) {
        print('Error occurred while polling Firestore: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Production Level'),
      ),
      body: Column(
        children: [
          Divider(height: 1, color: Colors.grey),
          SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionBox(
                    option: 'Basic Level Production',
                    icon: Icons.work_outline,
                    color: Colors.blue,
                    label: 'Basic',
                  ),
                  _buildOptionBox(
                    option: 'Medium',
                    icon: Icons.build,
                    color: Colors.orange,
                    label: 'Medium',
                  ),
                  _buildOptionBox(
                    option: 'High',
                    icon: Icons.security,
                    color: Colors.red,
                    label: 'High',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBox({
    required String option,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    bool isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () => _onOptionSelected(option),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.8) : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onOptionSelected(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption = option;
    });
    prefs.setString('selectedOption', option);
  }
}
