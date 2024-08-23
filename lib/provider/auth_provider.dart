import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

Future<void> signIn(String email, String password) async {
  try {
    _user = await _authService.signIn(email, password);
    notifyListeners();
  } catch (e) {
    log('Error during sign-in: $e');
    // Show error message to user
  }
}


Future<void> signUp(String email, String password) async {
  try {
    _user = await _authService.signUp(email, password);
    notifyListeners();
  } catch (e) {
    log(e.toString());
    // Handle error
  }
}


  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
