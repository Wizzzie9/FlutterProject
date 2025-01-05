import 'package:distance_check_app/widget_tree.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:distance_check_app/DistanceCheckPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:distance_check_app/firebase_api.dart';

class SendMessage extends StatefulWidget {
  const SendMessage({super.key});
  @override
  _SendMessage createState() => _SendMessage();
}

class _SendMessage extends State <SendMessage>  {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Chats');
  TextEditingController messageController = TextEditingController();
  String? destinationUid;
  String destinationFcmToken2='';
  final int messagesPerPage = 10;
  List<Widget> chatMessages = [];
  DatabaseEvent? lastSnapshot;
  bool isLoading = false;


  void initState() {
    super.initState();
    //loadMessages();
  }


  void sendData() {
    ref.child(destinationFcmToken2).push().set({'wiadomosc': messageController.text}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wysłano wiadomosc')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wysłać wiadomosci: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userName = arguments['userName']; // Odczytanie wartości userName
    final destinationFcmToken = arguments['destinationFcmToken']; // Odczytanie wartości destinationFcmToken
    print("dostalem token $destinationFcmToken");
    destinationFcmToken2 = destinationFcmToken;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      resizeToAvoidBottomInset: true, // przesun ui kiedy widac klawiature
      body: GestureDetector(
        child: Column(
          children: [
            Text("Czat z $userName"),
            Expanded(
              child: FirebaseAnimatedList(
                query: ref,
                itemBuilder: (context, snapshot, animation, index) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: ListTile(
                      title: Text(snapshot.child('Chats').value.toString()),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pole tekstowe
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Wpisz wiadomość',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null, // Umożliwia wieloliniowe pole tekstowe
                  ),
                  SizedBox(height: 10),
                  // Przycisk wysyłania wiadomości
                  ElevatedButton(
                    onPressed: () {
                      String message = messageController.text;
                      if (message.isNotEmpty) {
                        sendData();
                        print('Wiadomość: $message');
                        // Na przykład: wysyłanie wiadomości przez Firebase
                      }
                      messageController.clear(); // Wyczyść pole tekstowe po wysłaniu
                    },
                    child: Text('Wyślij'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}