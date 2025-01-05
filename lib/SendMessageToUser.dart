import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SendMessage extends StatefulWidget {
  const SendMessage({super.key});

  @override
  _SendMessage createState() => _SendMessage();
}

class _SendMessage extends State<SendMessage> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('Chats');
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController(); //  kontroler przewijania
  late String destinationFcmToken2;
  late String myFcmToken2;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    destinationFcmToken2 = arguments['destinationFcmToken'];
    myFcmToken2 = arguments['myFcmToken'];
    final userName = arguments['userName'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Czat z $userName"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: ref.onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final data = snapshot.data!.snapshot.value as Map;

                  // Pobieramy wiadomości z obu kolekcji
                  final messages = (data['$myFcmToken2$destinationFcmToken2'] ?? {})
                      .map((key, value) => MapEntry(key, {
                    'id': key,
                    'wiadomosc': value['wiadomosc'],
                    'timestamp': value['timestamp'],
                    'alignment': 'right',
                  }))
                      .values
                      .toList();

                  final otherMessages = (data['$destinationFcmToken2$myFcmToken2'] ?? {})
                      .map((key, value) => MapEntry(key, {
                    'id': key,
                    'wiadomosc': value['wiadomosc'],
                    'timestamp': value['timestamp'],
                    'alignment': 'left',
                  }))
                      .values
                      .toList();

                  // Połączenie wiadomości i sortowanie
                  final allMessages = [...messages, ...otherMessages]
                    ..sort((a, b) =>
                        int.parse(a['timestamp'].toString()).compareTo(int.parse(b['timestamp'].toString())));

                  // Automatyczne przewijanie na koniec
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scrollController.hasClients) {
                      scrollController.jumpTo(scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: scrollController, // Ustawiamy kontroler przewijania
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      final message = allMessages[index];
                      final alignment = message['alignment'] == 'right'
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                      final bgColor = message['alignment'] == 'right'
                          ? Colors.green[100]
                          : Colors.blue[100];
                      final content = message['wiadomosc'] ?? 'Brak wiadomości';

                      return Align(
                        alignment: alignment,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Text(content),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(child: Text("Brak wiadomości."));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: "Napisz wiadomość",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: sendData,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendData() {
    if (messageController.text.isNotEmpty) {
      ref.child('$myFcmToken2$destinationFcmToken2').push().set({
        'wiadomosc': messageController.text,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }).then((_) {
        messageController.clear();
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent); // Przewijanie po wysłaniu wiadomości
        }
      }).catchError((error) {
        print("Błąd podczas wysyłania wiadomości: $error");
      });
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose(); // Usunięcie kontrolera przewijania
    super.dispose();
  }
}

