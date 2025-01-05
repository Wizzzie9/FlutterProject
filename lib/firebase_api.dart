import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  String? fcmToken;

  Future<void> initNotifications() async {
    final permission = await _firebaseMessaging.requestPermission();

    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      print('Zgoda na powiadomienia udzielona');
    } else {
      print('Brak zgody na powiadomienia');
    }

    fcmToken = await _firebaseMessaging.getToken();
    print("Token: $fcmToken");

  }
  String? getToken() {
    return fcmToken;
  }
}