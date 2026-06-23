import 'package:bloc_todo/core/services/notification_service.dart';
import 'package:bloc_todo/core/utils/app_logger.dart';
import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/create_todo_state.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTodoCubit extends Cubit<CreateTodoState> {
  CreateTodoCubit({required this.repository, required this.notificationService})
    : super(const CreateTodoState());

  final TodoRepository repository;
  final NotificationService notificationService;

  Future<void> createTodo(TodoModel todo) async {
    if (state.status == CreateTodoStatus.submitting) return;

    emit(const CreateTodoState(status: CreateTodoStatus.submitting));

    late final TodoModel createdTodo;

    try {
      createdTodo = await repository.addTodo(todo);
    } catch (error) {
      emit(
        CreateTodoState(
          status: CreateTodoStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      return;
    }

    if (createdTodo.reminderAt == null || createdTodo.id == null) {
      emit(
        CreateTodoState(
          status: CreateTodoStatus.success,
          createdTodo: createdTodo,
        ),
      );
      return;
    }

    final notificationId = createdTodo.id!;

    try {
      await notificationService.scheduleTodoReminder(
        id: notificationId,
        title: createdTodo.title ?? 'Todo reminder',
        body: createdTodo.description ?? 'Your task is due soon',
        scheduledAt: createdTodo.reminderAt!,
        payload: createdTodo.id.toString(),
      );

      final todoWithNotification = createdTodo.copyWith(
        notificationId: notificationId,
      );

      try {
        await repository.updateTodo(todoWithNotification);
      } catch (error, stackTrace) {
        await notificationService.cancelNotification(notificationId);

        AppLogger.e(
          'Failed to persist the todo notification ID',
          error: error,
          stackTrace: stackTrace,
          data: {'todoId': createdTodo.id},
        );

        emit(
          CreateTodoState(
            status: CreateTodoStatus.success,
            createdTodo: createdTodo,
            warningMessage:
                'Todo created, but its reminder could not be saved.',
          ),
        );
        return;
      }

      emit(
        CreateTodoState(
          status: CreateTodoStatus.success,
          createdTodo: todoWithNotification,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.e(
        'Failed to schedule the todo reminder',
        error: error,
        stackTrace: stackTrace,
        data: {'todoId': createdTodo.id},
      );

      emit(
        CreateTodoState(
          status: CreateTodoStatus.success,
          createdTodo: createdTodo,
          warningMessage: 'Todo created, but the reminder was not scheduled.',
        ),
      );
    }
  }
}
