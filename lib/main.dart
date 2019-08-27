import 'package:flutter/material.dart';

import 'config.dart';
import 'routes.dart';

import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/container_form.dart';
import 'screens/container_filter.dart';
import 'screens/container.dart';

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.HOME:
            return MaterialPageRoute(builder: (_) => Homepage());
          case Routes.LOGIN:
            return MaterialPageRoute(builder: (_) => LoginPage());
          case Routes.CONTAINER_FORM:
            var shippingContainer;
            if (settings.arguments != null) {
              var arguments = settings.arguments as Map<String, dynamic>;
              shippingContainer = arguments[RouteContainerFormArguments.SHIPPING_CONTAINER];
            }
            return MaterialPageRoute(builder: (_) => ContainerForm(
              shippingContainer: shippingContainer,
            ));
          case Routes.CONTAINER_DETAIL:
            var shippingContainer;
            if (settings.arguments != null) {
              var arguments = settings.arguments as Map<String, dynamic>;
              shippingContainer = arguments[RouteContainerDetailArguments.SHIPPING_CONTAINER];
            }
            return MaterialPageRoute(builder: (_) => ContainerDetail(
              shippingContainer: shippingContainer,
            ));
          case Routes.CONTAINER_FILTER:
            var previousFilter;
            if (settings.arguments != null) {
              var arguments = settings.arguments as Map<String, dynamic>;
              previousFilter = arguments[RouteContainerFilterArguments.SHIPPING_CONTAINER_FILTER];
            }
            return MaterialPageRoute(builder: (_) => ContainerFilter(
              previousFilter: previousFilter,
            ));
        }
      },
      home: isAuthenticated ? Homepage() : LoginPage(),
    );
  }
}