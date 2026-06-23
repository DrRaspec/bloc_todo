import 'package:bloc_todo/core/utils/app_logger.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todo_state.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository repository;

  TodoCubit({required this.repository}) : super(TodoInitial());

  static const int _limit = 20;

  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  Future<void> loadTodos() async {
    try {
      emit(TodoLoading());

      _page = 0;
      _hasMore = true;

      final todos = await repository.getTodos(_page, _limit);

      if (todos.isEmpty) {
        emit(TodoEmpty());
        return;
      }

      _hasMore = todos.length == _limit;

      emit(TodoLoaded(todos: todos, hasMore: _hasMore));
    } catch (error, stackTrace) {
      AppLogger.e('Failed to load todos', error: error, stackTrace: stackTrace);
      emit(TodoError(message: error.toString()));
    }
  }

  Future<void> loadMoreTodos() async {
    final currentState = state;

    if (currentState is! TodoLoaded) return;
    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;

      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = _page + 1;

      final newTodos = await repository.getTodos(nextPage, _limit);

      _page = nextPage;
      _hasMore = newTodos.length == _limit;

      final allTodos = [...currentState.todos, ...newTodos];

      emit(
        TodoLoaded(todos: allTodos, hasMore: _hasMore, isLoadingMore: false),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Failed to load more todos',
        error: error,
        stackTrace: stackTrace,
      );
      emit(currentState.copyWith(isLoadingMore: false));
      emit(TodoError(message: error.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> toggleTodoCompleted(TodoModel todo) async {
    try {
      final updatedTodo = todo.copyWith(
        isCompleted: !(todo.isCompleted ?? false),
      );

      await repository.updateTodo(updatedTodo);

      final currentState = state;

      if (currentState is TodoLoaded) {
        final updatedTodos = currentState.todos.map((t) {
          return t.id == updatedTodo.id ? updatedTodo : t;
        }).toList();

        emit(currentState.copyWith(todos: updatedTodos));
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        'Failed to toggle todo completed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(TodoError(message: error.toString()));
    }
  }
}
