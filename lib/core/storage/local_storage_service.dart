import 'dart:io';

import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class LocalStorageService {
  static const dbName = 'todo.db';
  static const dbVersion = 1;
  static const tableName = 'todos';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnIsCompleted = 'isCompleted';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';

  String _databasesPath = '';
  String _path = '';
  Database? _database;

  Future<void> init() async {
    _databasesPath = await getDatabasesPath();

    await Directory(_databasesPath).create(recursive: true);

    _path = join(_databasesPath, dbName);

    if (kDebugMode) {
      print('Database path: $_path');
    }
  }

  bool isInitialized() {
    return _path.isNotEmpty && _databasesPath.isNotEmpty;
  }

  bool isOpen() {
    return _database != null && _database!.isOpen;
  }

  Future<void> open() async {
    if (!isInitialized()) {
      await init();
    }

    _database = await openDatabase(
      _path,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $tableName (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnTitle TEXT NOT NULL,
          $columnDescription TEXT,
          $columnIsCompleted INTEGER NOT NULL,
          $columnCreatedAt TEXT NOT NULL,
          $columnUpdatedAt TEXT NOT NULL
        )
      ''');
      },
    );
  }

  Future<TodoModel> insertTodo(TodoModel todo) async {
    if (!isOpen()) {
      await open();
    }

    final id = await _database!.insert(tableName, todo.toMap());
    return todo.copyWith(id: id);
  }

  Future<TodoModel?> getTodoById(int id) async {
    if (!isOpen()) {
      await open();
    }
    final List<Map<String, dynamic>> maps = await _database!.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TodoModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TodoModel>> getTodos(int page, int limit) async {
    if (!isOpen()) {
      await open();
    }
    final List<Map<String, dynamic>> maps = await _database!.query(
      tableName,
      limit: limit,
      offset: page * limit,
      orderBy: '$columnCreatedAt DESC',
    );
    return List.generate(maps.length, (i) {
      return TodoModel.fromMap(maps[i]);
    });
  }

  Future<int> updateTodo(TodoModel todo) async {
    if (!isOpen()) {
      await open();
    }
    return await _database!.update(
      tableName,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> completedTodo(int id) async {
    if (!isOpen()) {
      await open();
    }
    return await _database!.update(
      tableName,
      {columnIsCompleted: 1},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> unCompletedTodo(int id) async {
    if (!isOpen()) {
      await open();
    }
    return await _database!.update(
      tableName,
      {columnIsCompleted: 0},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(int id) async {
    if (!isOpen()) {
      await open();
    }
    return await _database!.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMultiTodo(List<int> id) async {
    if (!isOpen()) {
      await open();
    }
    final idString = id.join(', ');
    return await _database!.delete(
      tableName,
      where: '$columnId IN ($idString)',
    );
  }

  Future<int> deleteAllTodo() async {
    if (!isOpen()) {
      await open();
    }
    return await _database!.delete(tableName);
  }

  Future<void> close() async {
    if (isInitialized() && isOpen()) {
      await _database!.close();
    }
  }
}
