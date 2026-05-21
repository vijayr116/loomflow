import 'package:firebase_auth/firebase_auth.dart';

class LoginRepository {
  final FirebaseAuth _auth;
  LoginRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // 🔥 Clean error handling
      throw _mapFirebaseError(e);
    } catch (e) {
      throw "Something went wrong";
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found with this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'invalid-email':
        return "Invalid email format";
      case 'user-disabled':
        return "User account disabled";
      default:
        return "Login failed. Please try again";
    }
  }
}
