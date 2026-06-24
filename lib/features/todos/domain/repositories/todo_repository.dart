import 'package:bloc_todo/shared/enums/todo_filter.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';

abstract class TodoRepository {
  Future<TodoModel?> getTodoById(int id);
  Future<List<TodoModel>> getTodos(int page, int limit, TodoFilter filter);
  Future<TodoModel> addTodo(TodoModel todo);
  Future<int> updateTodo(TodoModel todo);
  Future<int> completedTodo(int id);
  Future<int> unCompletedTodo(int id);
  Future<int> deleteTodo(int id);
  Future<int> deleteMultiTodo(List<int> id);
  Future<int> deleteAllTodo();

  Future<List<TodoModel>> searchTodos({
    required String query,
    required TodoFilter filter,
  });
}
