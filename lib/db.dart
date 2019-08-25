import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'models/auth.dart';

class DatabaseHelper {
  static final _databaseName = "cms.db";
  static final _databaseVersion = 1;

  static final authTable = "auth";
  static final authColumnUsername = "username";
  static final authColumnPassword = "password";

  DatabaseHelper._initializeHelper();

  static Database _database;
  static final DatabaseHelper instance = DatabaseHelper._initializeHelper();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $authTable (
        $authColumnUsername TEXT PRIMARY KEY,
        $authColumnPassword TEXT
      ) 
      ''');
    //Seed db
    var defaultUser = AuthUser('admin');
    defaultUser.password = '@dmin011';
    await db.insert(authTable, defaultUser.toJson());
  }

  Future<int> updateAuthUser(AuthUser user) async {
    Database db = await instance.database;
    return await db.update(authTable, user.toJson());
  }

  Future<AuthUser> fetchUserWithUsername(String username) async {
    Database db = await instance.database;
    var user = await db.query(authTable, where: "$authColumnUsername = '$username'");
    if (user.length > 0)
      return AuthUser.fromJson(user.first);
    else
      return null;
  }
}