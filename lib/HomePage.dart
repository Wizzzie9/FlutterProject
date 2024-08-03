import 'package:flutter/material.dart';
import 'package:distance_check_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'BarcodeScannerPage.dart';
import 'DatabaseTestsPage.dart';
import 'DistanceCheckPage.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Menu główne');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'Adres email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
        onPressed: signOut,
        child: const Text('Wyloguj się'),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body:Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const DataBaseTests()),
              );
            },
            child: const Card(child: _SampleCard(cardName: 'Odczyt/zapis do bazy danych')),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const DistanceCheck()),
              );
            },
            child: const Card(child: _SampleCard(cardName: 'Lokalizacja na mapie')),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const Barcodescanner()),
              );
            },
            child: const Card(child: _SampleCard(cardName: 'Skaner kodów')),
          ),
          _userUid(),
          _signOutButton()
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
