import 'dart:io';

import 'package:bloc_todo/shared/enums/todo_filter.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

class LocalStorageService {
  static const dbName = 'todo.db';
  static const dbVersion = 4;
  static const tableName = 'todos';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnIsCompleted = 'isCompleted';
  static const columnPriority = 'priority';
  static const columnDueDate = 'dueDate';
  static const columnReminderAt = 'reminderAt';
  static const columnNotificationId = 'notificationId';
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
          $columnPriority INTEGER NOT NULL DEFAULT 0,
          $columnDueDate INTEGER,
          $columnReminderAt INTEGER,
          $columnNotificationId INTEGER,
          $columnCreatedAt INTEGER NOT NULL,
          $columnUpdatedAt INTEGER NOT NULL
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _alterTableAddColumn(
            db,
            columnPriority,
            'INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 3) {
          await _alterTableAddColumn(db, columnDueDate, 'INTEGER');
        }
        if (oldVersion < 4) {
          await _alterTableAddColumn(db, columnReminderAt, 'INTEGER');

          await _alterTableAddColumn(db, columnNotificationId, 'INTEGER');
        }
      },
    );
  }

  Future<void> _alterTableAddColumn(
    Database db,
    String columnName,
    String columnType,
  ) async {
    if (!await _isColumnExists(db, columnName)) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $columnName $columnType',
      );
    }
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

  Future<List<TodoModel>> getTodos(
    int page,
    int limit,
    TodoFilter filter,
  ) async {
    if (!isOpen()) {
      await open();
    }
    final List<Map<String, dynamic>> maps = await _database!.query(
      tableName,
      limit: limit,
      offset: page * limit,
      orderBy: '$columnCreatedAt DESC',
      where: _getFilterWhereClause(filter),
      whereArgs: _getFilterWhereArgs(filter),
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

  String? _getFilterWhereClause(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.active:
        return '$columnIsCompleted = 0';
      case TodoFilter.completed:
        return '$columnIsCompleted = 1';
      case TodoFilter.all:
        return null;
    }
  }

  List<dynamic>? _getFilterWhereArgs(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.active:
        return [0];
      case TodoFilter.completed:
        return [1];
      case TodoFilter.all:
        return null;
    }
  }

  Future<bool> _isColumnExists(Database db, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }
}
