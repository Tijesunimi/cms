import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'models/auth.dart';
import 'models/container.dart';

class DatabaseHelper {
  static final _databaseName = "cms.db";
  static final _databaseVersion = 1;

  static final authTable = "auth";
  static final authColumnUsername = "username";
  static final authColumnPassword = "password";

  static final containerTable = "containers";
  static final containerColumnId = "id";
  static final containerColumnContainerNo = "container_no";
  static final containerColumnShippingLine = "shipping_line";
  static final containerColumnExporter = "exporter";
  static final containerColumnImporter = "importer";
  static final containerColumnSize = "size";
  static final containerColumnProduce = "produce";
  static final containerColumnDestination = "destination";
  static final containerColumnShipmentPort = "shipment_port";
  static final containerColumnShipmentDate = "date_shipment";
  static final containerColumnFumigationDate = "date_fumigation";
  static final containerColumnDepartureDate = "date_departure";

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
    await db.execute('''
      CREATE TABLE $containerTable (
        $containerColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $containerColumnContainerNo TEXT,
        $containerColumnShippingLine TEXT,
        $containerColumnSize INTEGER,
        $containerColumnExporter TEXT,
        $containerColumnImporter TEXT,
        $containerColumnProduce TEXT,
        $containerColumnDestination TEXT,
        $containerColumnShipmentPort TEXT,
        $containerColumnDepartureDate TEXT,
        $containerColumnFumigationDate TEXT,
        $containerColumnShipmentDate TEXT
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

  Future<List<ShippingContainer>> fetchContainers() async {
    Database db = await instance.database;
    var response = await db.query(containerTable);
    return response.isNotEmpty ? response.map((c) => ShippingContainer.fromJson(c)).toList() : [];
  }

  Future<ShippingContainer> fetchContainer(int id) async {
    Database db = await instance.database;
    var response = await db.query(containerTable, where: "$containerColumnId = $id");
    return response.isNotEmpty ? ShippingContainer.fromJson(response.first) : null;
  }

  Future<int> insertContainer(ShippingContainer container) async {
    Database db = await instance.database;
    return await db.insert(containerTable, container.toJson());
  }

  Future<int> updateContainer(ShippingContainer container) async {
    Database db = await instance.database;
    return await db.update(containerTable, container.toJson(), where: "$containerColumnId = ${container.id}");
  }

  Future<int> deleteContainer(int id) async {
    Database db = await instance.database;
    return await db.delete(containerTable, where: "$containerColumnId = $id");
  }
}