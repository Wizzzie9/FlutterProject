import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }


  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if(currentUser != null) {
      await _firestore.collection('users').doc(currentUser?.uid).set({
        'uid': currentUser?.uid,
        'email': currentUser?.email,
        'profileCompleted': false
      });
    }
    getUserData();
  }

  Future<bool?> getUserData() async {
    try {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      if (userDocSnapshot.exists) {
        print(userDocSnapshot['profileCompleted']);
        return userDocSnapshot['profileCompleted'];
       // return userDocSnapshot.data() as Map<String, dynamic>?;
      } else {
        print("Dokument nie istnieje.");
        return null;
      }
    } catch (e) {
      print("Błąd podczas pobierania dokumentu: $e");
      return null;
    }
  }


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
