import 'package:distance_check_app/GetCurrentPosition.dart';
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
  double myLatitude = 0;
  double myLongitude = 0;
  double nearestLongitude = 0;
  double distanceBetweenUsers = 0;
  final List<Map<String, String>> latestEntries = [];



  // void getData() async{
  //   DataSnapshot data =  await FirebaseDatabase.instance.ref("Lokalizacje").get(); //get the data
  //   final dane = data.value as Map<String, dynamic>;
  //   print("Pobrane dane z bazy: $dane");
  // }

  void getData() async {
    DataSnapshot data = await FirebaseDatabase.instance.ref("Lokalizacje").get(); // get the data
    final dane = Map<String, dynamic>.from(data.value as Map<Object?, Object?>);  //konwersja
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
        return Future.error('Odmówiono uprawnień do lokalizacji');
      }
    }
    Position position = await GetPosition().determinePosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      myLatitude = latitude;
      myLongitude = longitude;
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
    ref.child('${user?.uid}').push().set({'userName': user?.displayName,'latitude': latitude, 'longitude': longitude}).then((_) {
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
    final snapshot = await ref.child('/Lokalizacje/').get();
    final flutterMapMath = FlutterMapMath();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (key != '${user?.uid}') {
          String latestSubKey;
          dynamic latestEntry;
          value.forEach((subKey, subValue) {
            latestSubKey = subKey;
            latestEntry = subValue;
          });

          if (latestEntry != null) {
            final userName = latestEntry['userName'];
            final latitude = latestEntry['latitude'];
            final longitude = latestEntry['longitude'];

            double distance = flutterMapMath.distanceBetween(
                latitude,
                longitude,
                myLatitude,
                myLongitude,
                "kilometers"
            );
            String roundedDistance = distance.toStringAsFixed(2);

            // Dodaj najnowszy wpis do mapy latestEntries
            latestEntries.add({
              'Name': userName.toString(),
              'uid': key,
              'latitude': latitude.toString(),
              'longitude': longitude.toString(),
              'distance': roundedDistance
            });
          }
        }
      });

      // latestEntries.forEach((entry) {
      //   print('name: ${entry['Name']},UID: ${entry['uid']}, Latitude: ${entry['latitude']}, Longitude: ${entry['longitude']}, Distance: ${entry['distance']}');
      // });

    } else {
      print('Brak danych');
    }

    setState(() {
      isLoading2 = false;
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
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.55,
            child: isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("Ładowanie mapy..."),
                ],
              ),
            )
                : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 17.0,
              ),
              markers: _markers,
            ),
          ),
          const SizedBox(height: 8), // Odstęp przed listą
          isLoading2
              ? const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 8),
                Text("Wczytywanie danych"),
              ],
            ),
          )
              : Flexible(
            child: ListView.builder(
              itemCount: latestEntries.length,
              itemBuilder: (context, index) {
                final entry = latestEntries[index];
                final latitude = entry['latitude'];
                final longitude = entry['longitude'];
                final distance = entry['distance'];
                final userName = entry['Name'];
                 return Column(
                   children: [
                     ListTile(
                      subtitle: Text('Imię: $userName \nLatitude: $latitude\nLongitude: $longitude\nDystans: $distance km'),
                     ),
                     const Divider(),
                   ],
                 );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Database",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "DistanceCheck",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "BarcodeScanner",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
