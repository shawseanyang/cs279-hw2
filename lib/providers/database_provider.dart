import 'package:flutter/cupertino.dart';
import 'package:flutter_todo_app/constants/colors.dart';
import 'package:flutter_todo_app/models/task.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

// Abstracts away the database logic
class DatabaseProvider {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = 'tasks';
  static final String _path = 'tasks.db';

  DatabaseProvider();

  // initialize the SQL database in the backend by creating a table for the tasks with a column for each of our fields and an auto-incrementing key field for the ID
  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String path = await getDatabasesPath() + _path;
      _db = await openDatabase(path,
          version: _version, onCreate: (db, version) => db.execute('''
         CREATE TABLE $_tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title STRING, note TEXT, date STRING,
          startTime STRING, endTime STRING,
          remind INTEGER, repeat STRING,
          color INTEGER, isCompleted INTEGER)
        '''));
    // display a snackbar error if we can't initialize the database
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error initializing database',
        backgroundColor: Color(0xFF212121),
        colorText: pinkClr,
      );
    }
  }

  // creates a new task
  static Future<int> insertTask(Task task) async {
    return await _db!.insert(_tableName, task.toMap());
  }

  // deletes a task
  static Future<int> deleteTask(String id) async {
    return await _db!.delete(_tableName, where: 'id=?', whereArgs: [id]);
  }

  // updates a task by looking it up by its ID
  static Future<int> updateTask(String id) async {
    return await _db!.rawUpdate('''
UPDATE $_tableName 
SET isCompleted = ?
WHERE id = ? 
''', [1, id]);
  }

  // grabs all our tasks
  static Future<List<Map<String, dynamic>>> queryTasks() async {
    return await _db!.query(_tableName);
  }
}
