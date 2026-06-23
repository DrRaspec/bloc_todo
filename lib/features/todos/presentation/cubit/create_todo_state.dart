import 'package:bloc_todo/shared/models/todo_model.dart';

enum CreateTodoStatus { initial, submitting, success, failure }

class CreateTodoState {
  const CreateTodoState({
    this.status = CreateTodoStatus.initial,
    this.createdTodo,
    this.errorMessage,
    this.warningMessage,
  });

  final CreateTodoStatus status;
  final TodoModel? createdTodo;
  final String? errorMessage;
  final String? warningMessage;
}
