import 'package:blook/services/database/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //get instance of the auth
  final _auth = FirebaseAuth.instance;

  //get currend user and id
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user is currently signed in.");
    }
    return user.uid;
  }

  //login
  Future<UserCredential> loginEmailPassword(String email, password) async {
    try {
      final userCredentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //register
  Future<UserCredential> registerEmailPassword(String email, password) async {
    try {
      final userCredentials = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredentials;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  //delete account
  Future<void> deleteAccpunt() async {
    User? user = getCurrentUser();

    if (user != null) {
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);
      await user.delete();
    }
  }
}
