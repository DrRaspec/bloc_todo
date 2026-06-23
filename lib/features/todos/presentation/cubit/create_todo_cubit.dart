import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/create_todo_state.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTodoCubit extends Cubit<CreateTodoState> {
  CreateTodoCubit({required this.repository}) : super(const CreateTodoState());

  final TodoRepository repository;

  Future<void> createTodo(TodoModel todo) async {
    if (state.status == CreateTodoStatus.submitting) return;

    emit(const CreateTodoState(status: CreateTodoStatus.submitting));

    try {
      final createdTodo = await repository.addTodo(todo);

      emit(
        CreateTodoState(
          status: CreateTodoStatus.success,
          createdTodo: createdTodo,
        ),
      );
    } catch (error) {
      emit(
        CreateTodoState(
          status: CreateTodoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
