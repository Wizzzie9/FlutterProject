import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:distance_check_app/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:distance_check_app/auth.dart';
import 'package:flutter/services.dart';
import 'package:distance_check_app/firebase_api.dart';


class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({super.key});
  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfile();
}
final TextEditingController _controllerUserName = TextEditingController();
final TextEditingController _controllerAge = TextEditingController();

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
User? get currentUser => _firebaseAuth.currentUser;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Auth auth = new Auth();


Widget _title() {
  return const Text('Uzupełnij swój profil, aby kontynuować');
}

Widget _card(TextEditingController controller, String name) {
  return Card(
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: name
      ),
    ),
  );
}

Widget _cardAge(TextEditingController controller, String age) {
  return Card(
    child: TextField(
      keyboardType: TextInputType.number,
       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(("[0-9]")))],
      controller: controller,
      decoration: InputDecoration(
        labelText: age
      ),
    ),
  );
}

Future<void> updateUserData(String name, int age) async {
  FirebaseApi firebaseApi = FirebaseApi();
  await firebaseApi.initNotifications();
  String? token = firebaseApi.getToken();

  if (currentUser != null) {
    await _firestore.collection('users').doc(currentUser?.uid).set({
      'uid': currentUser?.uid,
      'email': currentUser?.email,
      'profileCompleted': true,
      'imie': name,
      'wiek': age,
      'fcmToken': token
    });
    await currentUser?.updateProfile(displayName: name);
    await currentUser?.reload();
    print("Wysłano mail weryfikacyjny");
    await currentUser?.sendEmailVerification();
  }
}

Widget _submitButton(BuildContext context) {
  return ElevatedButton(
    onPressed: ()  async {
      String name = _controllerUserName.text;
      String ageText = _controllerAge.text;
      int? age = int.tryParse(ageText);
      if (age != null) {
        await updateUserData(name, age);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('Nieprawidłowa wartość');
      }
      updateUserData(name, int.parse(_controllerAge.text));
    },
    child: Text('Wyślij'),
  );
}


class _UpdateUserProfile extends State<UpdateUserProfile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _card(_controllerUserName, 'Imię'),
            _cardAge(_controllerAge, 'Wiek'),
            _submitButton(context),
          ],
        ),
      ),
    );
  }

}