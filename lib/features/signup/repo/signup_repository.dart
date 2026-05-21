import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SignupRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  Future<void> signup(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) throw "User creation failed";
      //saving user to firstore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        "email": user.email,
        "name": name,
        "role": role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      print("🔥 Firestore Error: $e");
      throw e.toString();
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email already in use";
      case 'invalid-email':
        return "Invalid email";
      case 'weak-password':
        return "Password should be at least 6 characters";
      default:
        return "Signup failed";
    }
  }
}
