import 'package:bloc_todo/shared/models/todo_model.dart';

abstract class TodoRepository {
  Future<TodoModel?> getTodoById(int id);
  Future<List<TodoModel>> getTodos(int page, int limit);
  Future<TodoModel> addTodo(TodoModel todo);
  Future<int> updateTodo(TodoModel todo);
  Future<int> completedTodo(int id);
  Future<int> unCompletedTodo(int id);
  Future<int> deleteTodo(int id);
  Future<int> deleteMultiTodo(List<int> id);
  Future<int> deleteAllTodo();
}
