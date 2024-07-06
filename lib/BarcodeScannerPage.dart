import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Barcodescanner extends StatefulWidget {
  const Barcodescanner({Key? key}) : super(key: key);

  @override
  _Barcodescanner createState() => _Barcodescanner();
}

class _Barcodescanner extends State<Barcodescanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcodescanner"),
      ),
    );
  }

}