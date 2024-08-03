import 'package:distance_check_app/BarcodeScannerPage.dart';
import 'package:distance_check_app/DistanceCheckPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';


class DataBaseTests extends StatefulWidget {
  const DataBaseTests({super.key});

  @override
  _DataBaseTestsState createState() => _DataBaseTestsState();
}

class _DataBaseTestsState extends State<DataBaseTests> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('myDatabase');
  final TextEditingController textInputController = TextEditingController();

  int _selectedIndex = 0;

  @override
  void dispose() {
    textInputController.dispose();
    super.dispose();
  }

  void sendData() {
    final text = textInputController.text;
    if (text.isNotEmpty) {
      ref.push().set({'name': text}).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wysłano tekst')),
        );
        textInputController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się wysłać tekstu: $error')),
        );
      });
    }
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(index);
      switch(index) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DistanceCheck()),
          );
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Barcodescanner()),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odczy/zapis do bazy danych'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textInputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Wpisz tekst do wysłania',
              ),
            ),
          ),
          OutlinedButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: sendData,
            child: const Text('Wyślij'),
          ),
          Expanded(
            child: FirebaseAnimatedList(
              query: ref,
              itemBuilder: (context, snapshot, animation, index) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: ListTile(
                    title: Text(snapshot.child('name').value.toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Baza danych"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Lokalizacja"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Skaner kodów"
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
