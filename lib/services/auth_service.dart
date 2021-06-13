import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizzywizzy/models/app_user.dart';

/// A set of methods that manages [FirebaseAuth] and [GoogleSignIn].
class AuthService {
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: ["email", "profile"]);
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static get appUser => _user;
  static AppUser _user = AppUser();
  static final List<String> domains = ["stu.naperville203.org", "naperville203.org"];

  static Future<void> signInWithGoogle() async {
    if (_auth.currentUser != null || _googleSignIn.currentUser != null)
      await signOutWithGoogle();
    final GoogleSignInAccount googleSignInAccount =
        await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    if (_googleSignIn.currentUser != null)
      await validateEmail(_googleSignIn.currentUser!.email);

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    IdTokenResult token = await authResult.user!.getIdTokenResult();
    if (token.claims!.containsKey("role"))
      _user.createInstance(authAccount: authResult.user, googleAccount: googleSignInAccount, role: token.claims!["role"]);
    else {
      _user.createInstance(authAccount: authResult.user, googleAccount: googleSignInAccount, role: "student");
      print("Failed to get role of user, defaulting to student");
    }
  }

  static Future<void> validateEmail(String email) async {
    List<String> emailSegments = email.split("@");
    if (!(emailSegments.length == 2 &&
        domains.contains(emailSegments[1]))) {
      final results = await FirebaseFunctions.instance
          .httpsCallable("validateEmail")
          .call({"email": email});
      if (!results.data["valid"]) {
        await signOutWithGoogle();
        throw PlatformException(code: "invalid-email");
      }
    }
  }

  static Future<void> signInSilently() async {
    if (_auth.currentUser != null) {
      await _googleSignIn.signInSilently();
      if (_googleSignIn.currentUser != null) {
        await validateEmail(_googleSignIn.currentUser!.email);
        IdTokenResult token = await _auth.currentUser!.getIdTokenResult();
        if (token.claims!.containsKey("role"))
          _user.createInstance(authAccount: _auth.currentUser, googleAccount: _googleSignIn.currentUser, role: token.claims!["role"]);
        else {
          _user.createInstance(authAccount: _auth.currentUser, googleAccount: _googleSignIn.currentUser, role: "student");
          print("Failed to get role of user, defaulting to student");
        }
      } 
    }
  }

  static Future<void> signOutWithGoogle() async {
    if (_auth.currentUser != null) await _auth.signOut();
    if (_googleSignIn.currentUser != null) await _googleSignIn.signOut();
    if (_user.exists) _user.deleteInstance();
  }

  static String getMessageFromSignInErrorCode(e) {
    switch (e.code) {
      case "popup_closed_by_user":
        return "Google Sign In OAuth consent screen closed by the user";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong email/password combination.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "operation-not-allowed":
        return "Server error, please try again later.";
        break;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Google account is not a valid Naperville 203 account";
        break;
      default:
        return "Login failed. Please try again.";
    }
  }

  static String getMessageFromSignOutErrorCode(e) {
    switch (e) {
      default:
        return "Error occurred while signing out.";
    }
  }
}
