import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'views/home.dart';
import 'views/course.dart';
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
      '/courses',
      handler: Handler(
        handlerFunc: (context, params) => HomeView(),
      ),
    )
    ..define(
      'courses/:course',
      handler: Handler(
        handlerFunc: (context, params) {
          final String course = params['course'][0];
          return CourseView(
            course: course,
          );
        },
      ),
    );

  runApp(QuizzyWizzyApp());
}

class QuizzyWizzyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizzyWizzy',
        home: FutureBuilder(
          future: _fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('You have an error! ${snapshot.error.toString}');
              return Text("Something went wrong!");
            } else if (snapshot.hasData) {
              return MaterialApp(
                title: 'QuizzyWizzy',
                onGenerateRoute: (settings) => FluroRouter.appRouter
                    .matchRoute(context, settings.name, routeSettings: settings)
                    .route,
                initialRoute: '/courses',
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
