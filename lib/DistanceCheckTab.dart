import 'package:distance_check_app/test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BarcodeScannerTab.dart';

class DistanceCheck extends StatefulWidget {
  const DistanceCheck({Key? key}) : super(key: key);

  @override
  _DistanceCheck createState() => _DistanceCheck();
}

class _DistanceCheck extends State<DistanceCheck> {
  int _selectedIndex = 1;

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