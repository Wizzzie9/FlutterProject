import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:distance_check_app/GetCurrentPosition.dart';
import 'package:distance_check_app/SendMessageToUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:distance_check_app/auth.dart';
import 'BarcodeScannerPage.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:distance_check_app/firebase_api.dart';


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
  bool isLoading3 = true;
  final User? user = Auth().currentUser;
  double myLatitude = 0;
  double myLongitude = 0;
  double nearestLongitude = 0;
  double distanceBetweenUsers = 0;
  final List<Map<String, String>> latestEntries = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? destinationFcmToken;
  String? destinationEmail;
  String? myFcmToken;



  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  void initState() {
    super.initState();
    GetLoc();
    FirebaseApi();
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

  Future<void> getUserData(String? uid) async {
    try {
      // pobranie danych z kolekcji 'users'
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      FirebaseApi firebaseApi = FirebaseApi();
      await firebaseApi.initNotifications();
      myFcmToken = firebaseApi.getToken();
      for (var doc in snapshot.docs) {
        if(doc['uid'] == uid){
          destinationFcmToken = doc['fcmToken'];
          destinationEmail = doc['email'];
          isLoading3 = false;
        }
      }
    } catch (e) {
      print("Błąd pobierania danych: $e");
    }
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
          dynamic latestEntry = value.values.last; // Pobierz ostatni element
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
                final uid = entry['uid'];
                 return Column(
                   children: [
                     ListTile(
                       trailing: IconButton(
                         icon: Icon(Icons.message),
                         color: Colors.orange,
                         iconSize: 35,
                         onPressed: () {
                           if (isLoading3) {
                             // Show loading message while waiting for data
                             showDialog(
                               context: context,
                               barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
                               builder: (BuildContext context) {
                                 return AlertDialog(
                                   title: Text('Loading Chat...'),
                                   content: CircularProgressIndicator(),
                                 );
                               },
                             );
                             // Simulate data loading by calling getUserData(uid)
                             getUserData(uid).then((_) {
                               // When data is loaded and isLoading3 is false, navigate to the next page
                               Navigator.pop(context); // Close the loading dialog
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => const SendMessage(),
                                   settings: RouteSettings(
                                     arguments: {
                                       'userName': userName,
                                       'destinationFcmToken': destinationFcmToken,
                                       'uid': uid,
                                       'email': destinationEmail,
                                       'myFcmToken': myFcmToken
                                     },
                                   ),
                                 ),
                               );
                               isLoading3 = true; // resetuje zmienna, zeby ponownie pobrac token. Jak nie zresetuje to po cofnieciu ekranu i przejsciu do innego czatu widac wiadomosci innej osoby
                             });
                           } else {
                             // If not loading, proceed to the next page immediately
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => const SendMessage(),
                                 settings: RouteSettings(
                                   arguments: {
                                     'userName': userName,
                                     'destinationFcmToken': destinationFcmToken,
                                     'uid': uid,
                                     'email': destinationEmail,
                                     'myFcmToken': myFcmToken
                                   },
                                 ),
                               ),
                             );
                           }
                         },

                       ),
                      subtitle: Text('Imię: $userName \nLatitude: $latitude\nLongitude: $longitude\nDystans: $distance km\nuid: $uid'),
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
