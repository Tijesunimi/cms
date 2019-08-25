import 'dart:async';

import 'package:cms/db.dart';

class AuthService {
  Future<bool> isAuthenticated() async {
    return false;
  }

  Future<bool> isValidUser(String username, String password) async {
    final db = DatabaseHelper.instance;
    var authUser = await db.fetchUserWithUsername(username);
    if (authUser != null) {
      return authUser.isPasswordEqual(password);
    }
    return false;
  }
}