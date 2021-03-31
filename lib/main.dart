import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/constants.dart';
import 'package:quizzywizzy/models/app_user.dart';
import 'package:quizzywizzy/models/ui_type.dart';
import 'package:quizzywizzy/services/auth_service.dart';
import 'package:flutter/foundation.dart';
//import 'package:quizzywizzy/services/configure_nonweb.dart' if (dart.library.html) 'package:quizzywizzy/services/configure_web.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Constants.emulatorUsed) {
    FirebaseFirestore.instance.settings = Settings(
        host: Constants.getFirestoreHost(
            defaultTargetPlatform == TargetPlatform.android),
        sslEnabled: false);
    FirebaseFunctions.instance.useFunctionsEmulator(
        origin: Constants.getFunctionsHost(
            defaultTargetPlatform == TargetPlatform.android));
  }
  await AuthService.signInSilently();
  //configureApp();
  runApp(QuizzyWizzyApp());
}

class QuizzyWizzyApp extends StatelessWidget {
  final delegate = AppRouterDelegate();
  final parser = AppRouteInformationParser();
  final UIType uiType = UIType();
  QuizzyWizzyApp() {
    Get.put(delegate);
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppUser>.value(
            value: AuthService.appUser,
          ),
          ChangeNotifierProvider<UIType>.value(value: uiType),
        ],
        child: MaterialApp.router(
          title: Constants.title,
          routerDelegate: delegate,
          routeInformationParser: parser,
        ));
  }
}
