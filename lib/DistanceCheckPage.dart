import 'package:distance_check_app/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:distance_check_app/auth.dart';
import 'BarcodeScannerPage.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';


class DistanceCheck extends StatefulWidget {
  const DistanceCheck({super.key});

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
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Lokalizacje');
  late GoogleMapController mapController;
  bool isLoading = true;
  bool isLoading2 = true;
  final User? user = Auth().currentUser;
  double nearestLatitude = 0;
  double nearestLongitude = 0;
  double distanceBetweenUsers = 0;

  void getData()async{ //use a Async-await function to get the data
    DataSnapshot data =  await FirebaseDatabase.instance.ref("Lokalizacje").get(); //get the data
    final dane = data.value as Map<String, dynamic>;
    print("Pobrane dane z bazy: $dane");
  }


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
      latitude = position.latitude;
      longitude = position.longitude;
      _center = LatLng(latitude, longitude);
    });

      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude
      );
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
        isLoading = false;
        sendData();
        readData();
      });
  }

  void sendData() {
    ref.child('${user?.uid}').push().set({'latitude': latitude, 'longitude': longitude}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wysłano lokalizację')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wysłać lokalizacji: $error')),
      );
    });
    }

  void readData() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('/Lokalizacje/bJ9AYTG8ZodYTx3cYTgGj4IqLdM2').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final latitude = value['latitude'];
        final longitude = value['longitude'];
        nearestLatitude = latitude;
        nearestLongitude = longitude;
      });
    } else {
      print('No data available.');
    }
    final flutterMapMath = FlutterMapMath();
    double distance = flutterMapMath.distanceBetween(
        latitude,
        longitude,
        nearestLatitude,
        nearestLongitude,
        "kilometers"
    );
    setState(() {
      isLoading2 = false;
      distanceBetweenUsers = double.parse(distance.toStringAsFixed(2));
    });
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch(index) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DistanceCheck()),
          );
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Barcodescanner()),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lokalizacja na mapie"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height * 0.65,
               // constraints: BoxConstraints(maxWidth: 300),
                child: isLoading ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Ładowanie mapy..."),
                  ],
                ) : GoogleMap(
                    onMapCreated: _onMapCreated ,
                    initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 17.0,
                     ),
                    markers: _markers,
                    ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Wyrównuje wszystkie elementy do lewej
            children: [
              const Row(
                children: [
                  Text("Najbliżsi użytkownicy"),
                ],
              ),
              const SizedBox(height: 8), // Odstęp między tekstem a informacją o ładowaniu
              isLoading2
                  ? const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8), // Odstęp między wskaźnikiem a tekstem
                  Text("wczytywanie danych"),
                ],
              )
                  : Text("$nearestLatitude | $nearestLongitude = $distanceBetweenUsers  km"),
            ],
          )


        ],
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