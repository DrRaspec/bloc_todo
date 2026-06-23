import 'package:bloc_todo/shared/models/todo_model.dart';

abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  final bool hasMore;
  final bool isLoadingMore;

  TodoLoaded({
    required this.todos,
    this.hasMore = true,
    this.isLoadingMore = true,
  });

  TodoLoaded copyWith({
    List<TodoModel>? todos,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class TodoError extends TodoState {
  final String message;

  TodoError({required this.message});
}

class TodoEmpty extends TodoState {}
