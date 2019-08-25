import 'package:dbcrypt/dbcrypt.dart';

class AuthUser {
  final String username;
  String _password;

  AuthUser(this.username);

  AuthUser.withPassword(this.username, this._password);

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser.withPassword(json['username'], json['password']);
  }

  set password(String password) {
    _password = DBCrypt().hashpw(password, DBCrypt().gensalt());
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': _password
    };
  }

  bool isPasswordEqual(String password) {
    return DBCrypt().checkpw(password, this._password);
  }
}