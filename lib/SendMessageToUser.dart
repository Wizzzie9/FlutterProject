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

class Message {
  final String content; // Treść wiadomości
  final String timestamp; // Znacznik czasu

  // Konstruktor
  Message({
    required this.content,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'Wiadomość: $content, Timestamp: $timestamp';
  }
}

class _SendMessage extends State<SendMessage> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Chats');
  TextEditingController messageController = TextEditingController();
  String? destinationUid;
  String destinationFcmToken2 = '';
  String myFcmToken2 = '';
  final int messagesPerPage = 10;
  List<Map<String, String>> chatMessages = [];
  List<Map<String, String>> chatMessages2 = [];
  DatabaseEvent? lastSnapshot;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseApi();
  }

  void sendData() {
    ref.child('$destinationFcmToken2$myFcmToken2').push().set(
        {'wiadomosc': messageController.text, 'timestamp': DateTime.now().millisecondsSinceEpoch}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wysłano wiadomość')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się wysłać wiadomości: $error')),
      );
    });
    readData(); // Po wysłaniu wiadomości, wczytujemy dane na nowo
  }

  void readData() {
    final dbpath1 = '$destinationFcmToken2$myFcmToken2';
    final dbpath2 = '$myFcmToken2$destinationFcmToken2';

    Future<void> loadMessages() async {
      final DatabaseEvent snapshot = await ref.child('$dbpath1').orderByChild('timestamp').limitToLast(10).once();
      final DatabaseEvent snapshot2 = await ref.child('$dbpath2').orderByChild('timestamp').limitToLast(10).once();
      // Sprawdzanie, czy dane istnieją
      if (snapshot.snapshot.exists || snapshot2.snapshot.exists) {
        List<Map<String, String>> newMessages = []; // Pomocnicza lista wiadomości
        List<Map<String, String>> newMessages2 = [];
        snapshot.snapshot.children.forEach((childSnapshot) {
          // Pobranie wiadomości i timestampu
          final content = childSnapshot.child('wiadomosc').value.toString();
          final timestamp = childSnapshot.child('timestamp').value.toString();
          // Dodanie mapy z wiadomością i timestampem do listy
          newMessages.add({
            'wiadomosc': content,
            'timestamp': timestamp,
          });
        });

        snapshot2.snapshot.children.forEach((childSnapshot) {
          // Pobranie wiadomości i timestampu
          final content = childSnapshot.child('wiadomosc').value.toString();
          final timestamp = childSnapshot.child('timestamp').value.toString();
          // Dodanie mapy z wiadomością i timestampem do listy
          newMessages2.add({
            'wiadomosc': content,
            'timestamp': timestamp,
          });
        });

        setState(() {
          chatMessages = newMessages; // Zaktualizowanie stanu po załadowaniu wiadomości
          chatMessages2 = newMessages2;
        });
      } else {
        print('Brak danych.');
      }

      print('Chat messages list: $chatMessages');
      print('Chat messages list: $chatMessages2');
    }
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userName = arguments['userName'];
    final destinationFcmToken = arguments['destinationFcmToken'];
    final myFcmToken = arguments['myFcmToken'];

    destinationFcmToken2 = destinationFcmToken;
    myFcmToken2 = myFcmToken;

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
              child: ListView.builder(
                itemCount: chatMessages.length + chatMessages2.length,  // Łączna liczba wiadomości
                itemBuilder: (context, index) {
                  var message;
                  bool isFromChatMessages = index < chatMessages.length;
                  if (isFromChatMessages) {
                    message = chatMessages[index];
                  } else {
                    message = chatMessages2[index - chatMessages.length];
                  }

                  return Align(
                    alignment: isFromChatMessages ? Alignment.centerLeft : Alignment.centerRight, // Wiadomości z chatMessages po lewej, z chatMessages2 po prawej
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isFromChatMessages ? Colors.blue[100] : Colors.green[100], // Kolor tła w zależności od źródła
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['wiadomosc'] ?? '',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            SizedBox(height: 5),
                            Text(
                              message['timestamp'] ?? '',
                              style: TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
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
                    maxLines: null, // wieloliniowe pole tekstowe
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      String message = messageController.text;
                      if (message.isNotEmpty) {
                        sendData();
                        print('Wiadomość: $message');
                      }
                      messageController.clear(); // czysci pole tekstowe po wyslaniu
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
