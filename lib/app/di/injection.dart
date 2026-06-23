import 'package:bloc_todo/core/storage/local_storage_service.dart';
import 'package:bloc_todo/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:get_it/get_it.dart';

class Injection {
  static final getIt = GetIt.instance;

  static Future<void> configureDependencies() async {
    final localStorageService = LocalStorageService();

    await localStorageService.init();
    await localStorageService.open();

    getIt.registerSingleton<LocalStorageService>(localStorageService);

    getIt.registerLazySingleton<TodoRepository>(
      () => TodoRepositoryImpl(localDb: getIt<LocalStorageService>()),
    );

    getIt.registerFactory<TodoCubit>(
      () => TodoCubit(repository: getIt<TodoRepository>()),
    );
  }
}
