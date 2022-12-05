import 'package:flutter/material.dart';
import 'package:plants_and_places/screens/login_screen.dart';
import 'package:plants_and_places/screens/signup_screen.dart';
import 'package:plants_and_places/widgets/map_page.dart';
import 'package:plants_and_places/widgets/upload_page.dart';

import 'screens/home_screen.dart';
import 'services.dart';
import 'widgets/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: RESTAPI.checkIfUserIsLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget initialRoute;

          if (!snapshot.hasData) {
            return DefaultLoading();
          } else {
            if (!snapshot.data) {
              initialRoute = SignupScreen();
            } else {
              initialRoute = HomeScreen();
            }
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Plants and places',
            theme: ThemeData(
              // https://coolors.co/b39c4d-768948-607744-34623f-1e2f23
              primaryColor: Color.fromRGBO(179, 156, 77, 1),
              accentColor: Color.fromRGBO(118, 137, 72, 1),
              backgroundColor: Color.fromRGBO(30, 47, 35, 1),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: initialRoute,
          );
        });
  }
}
