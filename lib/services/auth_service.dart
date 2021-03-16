import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizzywizzy/models/app_user.dart';
import 'package:quizzywizzy/constants.dart';

/// A set of methods that manages [FirebaseAuth] and [GoogleSignIn].
class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ["email", "profile"]);
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns [GoogleSignIn.onCurrentUserChanged].
  static get onGoogleUserChanged => _googleSignIn.onCurrentUserChanged;

  static AppUser _appUserFromFireBaseUser(User user) =>
      AppUser(uid: user.uid, displayName: user.displayName, email: user.email);

  static Stream<AppUser> get appUserStream =>
      _auth.authStateChanges().map(_appUserFromFireBaseUser);

  static Future<AppUser> signInWithGoogle() async {
    if (_auth.currentUser != null || _googleSignIn.currentUser != null)
      await signOutWithGoogle();
    //googleSignIn.hostedDomain = Constants.domains[Random().nextInt(2)];
    final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    List<String> gmailSegments = _googleSignIn.currentUser.email.split("@");
    if (!Constants.domains.contains(gmailSegments[1])) {
      await signOutWithGoogle();
      throw PlatformException(code: "invalid-domain");
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    if (user != null) {
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: ' + user.displayName);
    }
    return _appUserFromFireBaseUser(user);
  }

  static Future<void> signInSilently() async {
    await _googleSignIn.signInSilently();
    if (_googleSignIn.currentUser != null) {
      List<String> gmailSegments = _googleSignIn.currentUser.email.split("@");
      if (!Constants.domains.contains(gmailSegments[1])) {
        await signOutWithGoogle();
        throw PlatformException(code: "invalid-domain");
      }
    }
  }

  static Future<void> signOutWithGoogle() async {
    if (_auth.currentUser != null) await _auth.signOut();
    if (_googleSignIn.currentUser != null) await _googleSignIn.signOut();
    print("User Signed Out");
  }

  static String getMessageFromGoogleSignInErrorCode(e) {
    switch (e.code) {
      case "popup_closed_by_user":
        return "Google Sign In OAuth consent screen closed by the user";
      case "invalid-domain":
        return "Google Account does not have a valid domain: ${Constants.domains.toString()}";
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

  static String getMessageFromFireAuthErrorCode(e) {
    switch (e) {
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
        return "Email address is invalid.";
        break;
      default:
        return "Login failed. Please try again.";
    }
  }
}