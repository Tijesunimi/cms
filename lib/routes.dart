class Routes {
  static const String HOME = "/home";
  static const String LOGIN = "/login";
  static const String CONTAINER_FORM = "/form";
  static const String CONTAINER_DETAIL = "/container";
  static const String CONTAINER_FILTER = "/filter";
}

class RouteContainerFormArguments {
  static const String SHIPPING_CONTAINER = "shippingContainer";
}

class RouteContainerDetailArguments {
  static const String SHIPPING_CONTAINER = "shippingContainer";
}

class RouteContainerFilterArguments {
  static const String SHIPPING_CONTAINER_FILTER = "previousFilter";
}