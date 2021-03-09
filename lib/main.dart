import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/constants.dart' as Constants;
import 'package:quizzywizzy/services/auth_service.dart' as AuthService;
//import 'package:quizzywizzy/services/configure_nonweb.dart' if (dart.library.html) 'package:quizzywizzy/services/configure_web.dart';
import 'package:quizzywizzy/services/router.dart';
import 'models/app_user.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //configureApp();
  runApp(QuizzyWizzyApp());
}

class QuizzyWizzyApp extends StatelessWidget {
  final delegate = AppRouterDelegate();
  final parser = AppRouteInformationParser();
  QuizzyWizzyApp() {
    Get.put(delegate);
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          FutureProvider<FirebaseApp>(
            create: (context) => Firebase.initializeApp(),
            catchError: (context, error) {
              print("Error in loading Firebase: $error");
              return null;
            },
          ),
          FutureProvider<GoogleSignInAccount>(
              create: (context) {
                return AuthService.googleSignIn.signInSilently();
              },
              catchError: (context, error) {
                print("Error in Google Auto Sign In: $error");
                return null;
              }),
          StreamProvider<GoogleSignInAccount>.value(
            value: AuthService.googleSignIn.onCurrentUserChanged,
            catchError: (context, error) {
              print("Error in Google Stream: $error");
              return null;
            },
          ),
          StreamProvider<AppUser>.value(
            value: AuthService.appUserStream,
            catchError: (context, error) {
              print("Error in Auth Service Stream: $error");
              return null;
            },
          )
        ],
        child: MaterialApp.router(
          title: Constants.title,
          routerDelegate: delegate,
          routeInformationParser: parser,
        ));
  }
}
