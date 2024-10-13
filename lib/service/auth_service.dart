import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future LoginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      return e.message;
    }

    return false;
  }

  // Register user with email and password
  Future<bool> registerUserWithEmailandPassword(
      String fullName, String email, String password, String Phone) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await DataBaseService(uid: user.uid)
            .updataUserData(fullName, email, Phone);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }

    return false;
  }

  Future SignOut() async {
    try {
      await HelperFunctions.SaveUserLoggedInStatus(false);
      await HelperFunctions.SaveUserEmail("");
      await HelperFunctions.SaveUserName("");
      await HelperFunctions.SaveUserPhone("");
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }
}
