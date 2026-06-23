import 'package:bloc_todo/core/services/local_storage_service.dart';
import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/shared/enums/todo_filter.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';

class TodoRepositoryImpl extends TodoRepository {
  TodoRepositoryImpl({required this.localDb});

  final LocalStorageService localDb;

  @override
  Future<TodoModel> addTodo(TodoModel todo) {
    return localDb.insertTodo(todo);
  }

  @override
  Future<int> completedTodo(int id) {
    return localDb.completedTodo(id);
  }

  @override
  Future<int> deleteAllTodo() {
    return localDb.deleteAllTodo();
  }

  @override
  Future<int> deleteMultiTodo(List<int> id) {
    return localDb.deleteMultiTodo(id);
  }

  @override
  Future<int> deleteTodo(int id) {
    return localDb.deleteTodo(id);
  }

  @override
  Future<TodoModel?> getTodoById(int id) {
    return localDb.getTodoById(id);
  }

  @override
  Future<List<TodoModel>> getTodos(int page, int limit, TodoFilter filter) {
    return localDb.getTodos(page, limit, filter);
  }

  @override
  Future<int> unCompletedTodo(int id) {
    return localDb.unCompletedTodo(id);
  }

  @override
  Future<int> updateTodo(TodoModel todo) {
    return localDb.updateTodo(todo);
  }
}
