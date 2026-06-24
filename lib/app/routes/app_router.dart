import 'package:bloc_todo/app/di/injection.dart';
import 'package:bloc_todo/app/routes/app_routes.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/create_todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/pages/create_todo_page.dart';
import 'package:bloc_todo/features/todos/presentation/pages/edit_todo_page.dart';
import 'package:bloc_todo/features/todos/presentation/pages/home_page.dart';
import 'package:bloc_todo/features/todos/presentation/pages/todo_detail_page.dart';
import 'package:bloc_todo/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,

    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => Injection.getIt<TodoCubit>()..loadTodos(),
            child: const HomePage(),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.createTodo,
            builder: (context, state) {
              return BlocProvider(
                create: (_) => Injection.getIt<CreateTodoCubit>(),
                child: const CreateTodoPage(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.editTodo,
            builder: (context, state) {
              final todoId = int.tryParse(state.pathParameters['id'] ?? '');

              if (todoId == null) {
                return const EditTodoPage(todoId: -1);
              }

              return EditTodoPage(todoId: todoId);
            },
          ),
          GoRoute(
            path: AppRoutes.todoDetail,
            builder: (context, state) {
              final todoId = int.tryParse(state.pathParameters['id'] ?? '');

              if (todoId == null) {
                return const TodoDetailPage(todoId: -1);
              }

              return TodoDetailPage(todoId: todoId);
            },
          ),
        ],
      ),
    ],
  );
}
