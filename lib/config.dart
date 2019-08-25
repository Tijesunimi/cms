import 'package:flutter/material.dart';

class Config extends InheritedWidget {
  final Widget child;

  Config({this.child});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}