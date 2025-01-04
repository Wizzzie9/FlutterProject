import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:distance_check_app/LoginRegisterPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Przypomnienie hasła',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PasswordReminderPage(),
    );
  }
}

class PasswordReminderPage extends StatefulWidget {
  @override
  _PasswordReminderPageState createState() => _PasswordReminderPageState();
}

Future<void> sendPassword(_emailController) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
  } catch (e) {
    print('Błąd podczas wysyłania wiadomości: $e');
    return null;
  }
}

class _PasswordReminderPageState extends State<PasswordReminderPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailSent = false;
  void _sendEmail() {
    String email = _emailController.text;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proszę podać adres email")),
      );
    } else {
      sendPassword(_emailController);
      setState(() {
        _isEmailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Przypomnienie hasła'),
      ),
      body: Center(
        child: _isEmailSent
            ? Column(
          children: [
            Text(
              'Jeśli istnieje konto powiązane z podanym adresem email, zostanie na niego wysłany link do zresetowania hasła.',
              style: TextStyle(fontSize: 16),
            ),
            TextButton(  onPressed: () {
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => LoginPage()));
      }, child: Text("Wróć do logowania"),)
          ],
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wpisz adres email, aby przypomnieć hasło:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Adres email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendEmail,
                child: Text('Wyślij email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
