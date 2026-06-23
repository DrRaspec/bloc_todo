import 'package:bloc_todo/shared/models/todo_model.dart';

enum CreateTodoStatus { initial, submitting, success, failure }

class CreateTodoState {
  const CreateTodoState({
    this.status = CreateTodoStatus.initial,
    this.createdTodo,
    this.errorMessage,
  });

  final CreateTodoStatus status;
  final TodoModel? createdTodo;
  final String? errorMessage;
}
