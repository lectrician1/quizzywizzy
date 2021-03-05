import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/constants.dart' as Constants;
import 'package:quizzywizzy/services/auth_service.dart' as AuthService;
import 'package:quizzywizzy/views/initial.dart';
import 'models/app_user.dart';
import 'views/home.dart';
import 'views/route_not_found.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FluroRouter.appRouter.notFoundHandler = Handler(
    handlerFunc: (context, params) =>
        RouteNotFoundView(name: Uri.base.toString()),
  );
  FluroRouter.appRouter
    ..define(
      '/',
      transitionType: TransitionType.fadeIn,
      handler: Handler(
        handlerFunc: (context, params) => InitialView().redirect(context),
      ),
    );

  for(int i=0; i<=Constants.mainHierarchy.length; i++) {
    List<String> currentHierarchy = List.generate(i, (j) => Constants.mainHierarchy[j]);
    FluroRouter.appRouter.define(
      Constants.getRouteFluro(currentHierarchy),
      transitionType: TransitionType.fadeIn,
      handler: Handler(
        handlerFunc: (context, params) {
          return HomeView(List.generate(i, (j) => params[currentHierarchy[j]][0]));
        },
      ),
    );
  }
  runApp(QuizzyWizzyApp());
}

class QuizzyWizzyApp extends StatelessWidget {
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
        child: MaterialApp(
          title: Constants.title,
          onGenerateRoute: (settings) =>
              FluroRouter.appRouter.generator(settings),
        ));
  }
}
