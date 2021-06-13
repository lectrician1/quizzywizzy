import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppUser extends ChangeNotifier {
  User? _authAccount;
  GoogleSignInAccount? _googleAccount;
  String? _role;
  bool _exists;
  get authAccount => _authAccount;
  get googleAccount => _googleAccount;
  get role => _role;
  get exists => _exists;
  AppUser() : _exists = false;
  createInstance({required User? authAccount, required GoogleSignInAccount? googleAccount, required String? role}) {
    _authAccount = authAccount;
    _googleAccount = googleAccount;
    _role = role;
    _exists = true;
    notifyListeners();
  }
  deleteInstance() {
    _authAccount = null;
    _googleAccount = null;
    _role = null;
    _exists = false;
    notifyListeners();
  }
}
