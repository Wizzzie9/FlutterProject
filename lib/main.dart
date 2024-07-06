import 'package:distance_check_app/DatabaseTestsTab.dart';
import 'package:distance_check_app/firebase_api.dart';
import 'package:distance_check_app/firebase_options.dart';
import 'package:distance_check_app/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'DistanceCheckTab.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Teścik bazy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
String? _lokalizacja;

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
    _lokalizacja = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          GestureDetector(
           onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  DataBaseTests()),
              );
           },
            child: Card(child: _SampleCard(cardName: 'Database tests')),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  DistanceCheck()),
              );
            },
            child: Card(child: _SampleCard(cardName: 'Distance Check')),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  DataBaseTests()),
              );
            },
            child: Card(child: _SampleCard(cardName: 'Barcode Scanner')),
          ),
          GestureDetector(
            child: Card(child: _SampleCard(cardName: _lokalizacja ?? 'Loading...')),
          ),
        ],
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.cardName});
  final String cardName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 100,
      child: Center(child: Text(cardName),),
    );
  }
}
