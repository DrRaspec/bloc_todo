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
    } catch (e) {
      emit(TodoError(message: e.toString()));
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
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      emit(TodoError(message: e.toString()));
    } finally {
      _isLoading = false;
    }
  }
}
