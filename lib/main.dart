import 'package:flutter/material.dart';

import 'config.dart';
import 'routes.dart';

import 'screens/login.dart';
import 'screens/home.dart';

import 'services/auth.dart';

void main() async {
  var authService = AuthService();
  bool isAuthenticated = await authService.isAuthenticated();

  runApp(Config(
    child: CMS(
      isAuthenticated: isAuthenticated,
    ),
  ));
}

class CMS extends StatelessWidget {
  final bool isAuthenticated;

  CMS({this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Container Management System",
      routes: {
        Routes.HOME: (context) => Homepage(),
        Routes.LOGIN: (context) => LoginPage()
      },
      home: isAuthenticated ? Homepage() : LoginPage(),
    );
  }
}