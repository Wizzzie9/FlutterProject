import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:distance_check_app/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Log In or Sign Up to proceed');
  }

  Widget _emailEntryField(
      String title,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _passwordEntryField(
      String title,
      TextEditingController controller,
      ) {
    return TextField(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  // Widget _userName(
  //     String title,
  //     TextEditingController controller,
  //     ) {
  //   return TextField(
  //     obscureText: true,
  //     enableSuggestions: false,
  //     autocorrect: false,
  //     controller: controller,
  //     decoration: InputDecoration(
  //       labelText: title,
  //     ),
  //   );
  // }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
        child: Text(isLogin ? 'Zaloguj się' : 'Załóż konto'),
    );
  }


  Widget _loginOrRegisterButton() {
    return TextButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? 'Załóż konto' : 'Zaloguj się'),
    );
  }


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
            _emailEntryField('Adres email', _controllerEmail),
            _passwordEntryField('Hasło', _controllerPassword),
           // _userName('Twoje imię', _controllerUserName),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton()
          ],
        ),
      ),
    );
  }
}
