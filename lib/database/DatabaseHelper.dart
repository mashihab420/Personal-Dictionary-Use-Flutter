import 'dart:io';


import 'package:flutter/services.dart';
import 'package:personal_dictionary_with_sync/model/Words.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _DB_NAME = 'pdictionary.db';
  static final _DB_VERSION = 1;
  static final table = 'words';
  static final columnId = 'id';
  static final columnEnglish = 'english';
  static final columnBangla = 'bangla';
  static var status = '';

  //Constructor
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, _DB_NAME);

    //Check existing
    var exists = await databaseExists(path);
    if (!exists) {
      status = "Creating Database";

      //If not exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      //copy database
      ByteData data = await rootBundle.load(join("assets/db", _DB_NAME));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      //Write
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      status = "Opening existing database";
      print('Opening existing database');
    }

    return await openDatabase(path, version: _DB_VERSION);
  }

  //Insert
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  //InsertAll
  //Insert
  void insertAll(List<Words> words) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    words.forEach((row) {
      Words word = Words.fromJson(row.toJson());
      batch.insert(table, word.toJson());
    });

    batch.commit(continueOnError: true, noResult: true);

  }

//Get
  Future<List> getAll() async {
    Database db = await instance.database;
    var result = await db.query(table);
    return result.toList();
  }

  //Count
  Future<int> getTotalCount() async {
    var db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(id) FROM $table'));
  }

  //Delete
  Future<int> delete(String id) async {
    Database db = await instance.database;

    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  //delete all
  //Delete
  Future<int> deleteAll() async {
    Database db = await instance.database;

    return await db.rawDelete("DELETE FROM $table");
  }
}
