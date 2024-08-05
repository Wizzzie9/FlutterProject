import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:distance_check_app/auth.dart';

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({super.key});
  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfile();
}

final User? user = Auth().currentUser;

class _UpdateUserProfile extends State<UpdateUserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("sdasdasdasd"),
          ],
        ),
      ),
    );
  }

}