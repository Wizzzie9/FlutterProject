import 'package:flutter/material.dart';
import 'package:distance_check_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'BarcodeScannerPage.dart';
import 'DatabaseTestsPage.dart';
import 'DistanceCheckPage.dart';


class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key:key);
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
        onPressed: signOut,
        child: const Text('Sign Out'),
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
                MaterialPageRoute(builder: (context) =>  Barcodescanner()),
              );
            },
            child: Card(child: _SampleCard(cardName: 'Barcode Scanner')),
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
