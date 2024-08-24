import 'package:distance_check_app/LoginRegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:distance_check_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'DatabaseTestsPage.dart';
import 'DistanceCheckPage.dart';
import 'UpdateUserProfile.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final User? user = Auth().currentUser;

  Widget _signOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await auth.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } catch (e) {
          print('Error signing out: $e');
        }
      },
      child: const Text('Sign Out'),
    );
  }

  Widget _title() {
    return const Text('Menu główne');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'Adres email');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: _title(),
      ),
      body:FutureBuilder(
        future: auth.getUserName(),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Loading
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Text("Witaj, ${snapshot.data}!"),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  const DataBaseTests()),
                    );
                  },
                  child: const Card(child: _SampleCard(cardName: 'Odczyt/zapis do Firestore')),
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
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) =>  const Barcodescanner()),
                //     );
                //   },
                //   child: const Card(child: _SampleCard(cardName: 'Skaner kodów')),
                // ),
                _userUid(),
                _signOutButton(context)
              ],
            );
          } else {
            return Text('No data');
          }
        },
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
