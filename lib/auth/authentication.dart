import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>['email']
);
void onGoogleSignIn(BuildContext context) async {
   User user = await _handleSignIn();
   var userSignedIn = Navigator.push(
      context,
      MaterialPageRoute(
         builder: (context) =>
         WelcomeUserWidget(user, _googleSignIn)));
   setState(() {
      isUserSignedIn = userSignedIn == null ? true : false;
   });
}

Future<User> _handleSignIn() async {
   // hold the instance of the authenticated user
   User user;
   // flag to check whether we're signed in already
   bool isSignedIn = await _googleSignIn.isSignedIn();
   setState(() {
      isUserSignedIn = userSignedIn;
   });
   if (isSignedIn) {
      // if so, return the current user
      user = _auth.currentUser;
   }
   else {
      final GoogleSignInAccount googleUser = 
         await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = 
         await googleUser.authentication;
      // get the credentials to (access / id token)
      // to sign in via Firebase Authentication 
      final AuthCredential credential =
         GoogleAuthProvider.getCredential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken
         );
      user = (await _auth.signInWithCredential(credential)).user;
      userSignedIn = await _googleSignIn.isSignedIn();
      setState(() {
         isUserSignedIn = userSignedIn;
      });
   }
 
   return user;
}
