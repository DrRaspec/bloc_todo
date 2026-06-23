import 'package:bloc_todo/core/services/local_storage_service.dart';
import 'package:bloc_todo/core/services/notification_service.dart';
import 'package:bloc_todo/core/utils/app_logger.dart';
import 'package:bloc_todo/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/create_todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:get_it/get_it.dart';

class Injection {
  static final getIt = GetIt.instance;

  static Future<void> configureDependencies() async {
    final localStorageService = LocalStorageService();

    await localStorageService.init();
    await localStorageService.open();

    getIt.registerSingleton<LocalStorageService>(localStorageService);

    final notificationService = NotificationService.instance;
    getIt.registerSingleton<NotificationService>(notificationService);

    try {
      await notificationService.init();
    } catch (error, stackTrace) {
      AppLogger.e(
        'Notification service initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    getIt.registerLazySingleton<TodoRepository>(
      () => TodoRepositoryImpl(localDb: getIt<LocalStorageService>()),
    );

    getIt.registerFactory<TodoCubit>(
      () => TodoCubit(repository: getIt<TodoRepository>()),
    );

    getIt.registerFactory<CreateTodoCubit>(
      () => CreateTodoCubit(repository: getIt<TodoRepository>()),
    );
  }
}
