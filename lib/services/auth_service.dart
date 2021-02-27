import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizzywizzy/models/app_user.dart';
import 'package:quizzywizzy/constants.dart' as Constants;

final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ["email", "profile"], hostedDomain: Constants.domains[0]);
final FirebaseAuth _auth = FirebaseAuth.instance;

AppUser _appUserFromFireBaseUser(User user) =>
    AppUser(uid: user.uid, displayName: user.displayName, email: user.email);

Stream<AppUser> get appUserStream =>
    _auth.authStateChanges().map(_appUserFromFireBaseUser);

Future<AppUser> signInWithGoogle() async {
  if (_auth.currentUser != null || googleSignIn.currentUser != null) await signOutWithGoogle();
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
  if (googleSignIn.currentUser != null) print(googleSignIn.currentUser.email);
  
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

Future<void> signOutWithGoogle() async {
  if (_auth.currentUser != null) await _auth.signOut();
  if (googleSignIn.currentUser != null) await googleSignIn.signOut();
  print("User Signed Out");
}
