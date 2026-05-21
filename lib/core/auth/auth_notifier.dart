import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends ChangeNotifier {
  User? user;
  bool isLoading = true;
  AuthNotifier() {
    FirebaseAuth.instance.idTokenChanges().listen((u) {
      user = u;
      isLoading = false;
      notifyListeners();
    });
  }
}
