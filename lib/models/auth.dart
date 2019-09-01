import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthUser {
  final String username;
  String _password;

  AuthUser(this.username);

  AuthUser.withPassword(this.username, this._password);

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser.withPassword(json['username'], json['password']);
  }

  set password(String password) {
    this._password = md5.convert(utf8.encode(password)).toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': _password
    };
  }

  bool isPasswordEqual(String password) {
    var hashedPassword = md5.convert(utf8.encode(password)).toString();
    return hashedPassword == this._password;
  }
}