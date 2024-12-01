import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Text above SOS button
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              "Emergency help needed?",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await _checkAndRequestPermission();
                  FlutterPhoneDirectCaller.callNumber('+91112');
                },
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildEmergencyButton(
                      context, '100 Police', Icons.local_police, Colors.blue),
                  _buildEmergencyButton(context, '101 Fire Engine',
                      Icons.local_fire_department, Colors.orange),
                  _buildEmergencyButton(context, '108 Ambulance',
                      Icons.local_hospital, Colors.green),
                  _buildEmergencyButton(context, 'Trusted Contact',
                      Icons.contact_phone, Colors.purple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
      BuildContext context, String label, IconData icon, Color color) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          _handleEmergencyButton(label);
        },
        child: Container(
          width: 120.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30.0,
              ),
              SizedBox(height: 8.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEmergencyButton(String label) async {
    String phoneNumber;

    switch (label) {
      case '100 Police':
        phoneNumber = '100';
        break;
      case '101 Fire Engine':
        phoneNumber = '101';
        break;
      case '108 Ambulance':
        phoneNumber = '108';
        break;
      case 'Trusted Contact':
        phoneNumber = '9952672209';
        break;
      default:
        print('Unknown emergency type');
        return;
    }

    await _checkAndRequestPermission();
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  Future<void> _checkAndRequestPermission() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      await Permission.phone.request();
    }
  }
}
