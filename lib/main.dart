import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quizzywizzy/constants.dart';
import 'package:quizzywizzy/models/app_user.dart';
import 'package:quizzywizzy/models/ui_type.dart';
import 'package:quizzywizzy/services/auth_service.dart';
//import 'package:quizzywizzy/services/configure_nonweb.dart' if (dart.library.html) 'package:quizzywizzy/services/configure_web.dart';
import 'package:quizzywizzy/services/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AuthService.signInSilently();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  setPathUrlStrategy();

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
