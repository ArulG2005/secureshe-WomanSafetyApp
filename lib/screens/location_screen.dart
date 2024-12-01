import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _currentLocation;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeMarkers();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);

      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: 'Your Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );

      _loadingLocation = false;

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    });
  }

  void _initializeMarkers() {
    setState(() {
      _markers.addAll([
        Marker(
          markerId: MarkerId('police_station'),
          position: LatLng(11.357615, 77.892299),
          infoWindow: InfoWindow(title: 'Police Station'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: MarkerId('hospital'),
          position: LatLng(11.376396, 77.894272),
          infoWindow: InfoWindow(title: 'Hospital'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingLocation
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14.0,
              ),
              markers: _markers,
            ),
    );
  }
}
