import 'package:flutter/material.dart';

class Barcodescanner extends StatefulWidget {
  const Barcodescanner({super.key});

  @override
  _Barcodescanner createState() => _Barcodescanner();
}

class _Barcodescanner extends State<Barcodescanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skaner kodów"),
      ),
    );
  }

}