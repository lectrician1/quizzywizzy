import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'views/home.dart';
import 'views/course.dart';
import 'views/route_not_found.dart';
//import 'router.dart' as router;
void main() {
  FluroRouter.appRouter.notFoundHandler = Handler(
    handlerFunc: (context, params) => RouteNotFoundView(name: Uri.base.toString()),
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizzyWizzy',
      onGenerateRoute: (settings) => FluroRouter.appRouter
      .matchRoute(context, settings.name, routeSettings: settings)
      .route,
      initialRoute: '/courses',
    );
  }
}