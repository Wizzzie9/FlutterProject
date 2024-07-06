import 'package:distance_check_app/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import 'BarcodeScannerTab.dart';

class DistanceCheck extends StatefulWidget {
  const DistanceCheck({Key? key}) : super(key: key);

  @override
  _DistanceCheck createState() => _DistanceCheck();
}

class _DistanceCheck extends State<DistanceCheck> {
  int _selectedIndex = 1;
  late double latitude;
  late double longitude;
  late LatLng _center;
  String _address = '';
  final Set<Marker> _markers = {};

  //String? _lokalizacja;
  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  void initState() {
    super.initState();
    GetLoc();
  }

  Future<void> GetLoc() async {
    LocationPermission permission;
    print(permission = await Geolocator.checkPermission());
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    Position position = await GetPosition().determinePosition();
    setState(() {
      //_lokalizacja = '${position.latitude} ${position.longitude}';
      latitude = position.latitude;
      longitude = position.longitude;
      _center = LatLng(latitude, longitude);
    });
    print("LOKJALIZACJA $_center");
    print("LATITUDE: $latitude");

      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude
      );

     // print("placemarks: $placemarks");
      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;
        final String address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        setState(() {
          _address = address;
        });
      } else {
        setState(() {
          _address = "Nie udało się pobrać adresu";
        });
      }

      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId(_center.toString()),
              position: _center,
              infoWindow: InfoWindow(
                title: "Wybrana lokalizacja",
                snippet: _address
              )
          )
        );
      });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(index);
      switch(index) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DistanceCheck()),
          );
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Barcodescanner()),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DistanceCheck"),
      ),
      body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 17.0,
           ),
          markers: _markers,
          ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Database"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "DistanceCheck"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "BarcodeScanner"
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}