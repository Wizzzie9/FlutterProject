import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../LoginRegisterPage.dart';
import 'package:distance_check_app/auth.dart';
import 'package:distance_check_app/HomePage.dart';
import '../UpdateUserProfile.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

final User? user = Auth().currentUser;

class _WidgetTreeState extends State<WidgetTree> {
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        print("Wracam");
        if (!snapshot.hasData) {
          return const LoginPage(); // lub inny widget dla przypadku braku danych
        }
        // Jeżeli mamy dane w snapshot, to musimy poczekać na getUserData
        return FutureBuilder<bool?>(
          future: auth.getUserData(),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // lub inny wskaźnik ładowania
            }
            if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }
            if (futureSnapshot.hasData) {
              bool? userData = futureSnapshot.data;
              if (userData == false) {
                return UpdateUserProfile();
              } else if (userData == true) {
                return HomePage();
              }
              else {
                return HomePage();
              }
            } else {
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}