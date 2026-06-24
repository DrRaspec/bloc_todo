import 'package:bloc_todo/core/utils/app_logger.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_state.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_shimmer_view.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_error_view.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_view.dart';
import 'package:bloc_todo/shared/enums/todo_filter.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - 200) {
        context.read<TodoCubit>().loadMoreTodos();
      }
    });
  }

  Future<void> onCompletedChanged(TodoModel todo, bool? value) async {
    if (value == null) return;

    await context.read<TodoCubit>().toggleTodoCompleted(todo);
  }

  Future<void> changeFilter(TodoFilter filter) async {
    await context.read<TodoCubit>().changeFilter(filter);
    AppLogger.d('Filter changed to: ${filter.index}');
    setState(() {
      selectedFilterIndex = filter.index;
    });
  }

  Future<void> onSearchSubmitted(String query) async {
    await context.read<TodoCubit>().searchTodos(
      query: query,
      filter: TodoFilter.values[selectedFilterIndex],
    );
  }

  Future<void> onDelete(int id) async {
    await context.read<TodoCubit>().deleteTodo(id);
  }

  Future<void> onRefresh() async {
    await context.read<TodoCubit>().loadTodos();
  }

  Future<void> onRetry() async {
    await context.read<TodoCubit>().loadTodos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return const HomeShimmerView();
          }

          if (state is TodoEmpty) {
            return HomeView(
              todos: const [],
              scrollController: _scrollController,
              selectedFilterIndex: selectedFilterIndex,
              changeFilter: changeFilter,
            );
          }

          if (state is TodoError) {
            return HomeErrorView(onRetry: context.read<TodoCubit>().loadTodos);
          }

          if (state is TodoLoaded) {
            return HomeView(
              todos: state.todos,
              scrollController: _scrollController,
              changeFilter: changeFilter,
              selectedFilterIndex: selectedFilterIndex,
              onCompletedChanged: onCompletedChanged,
              onSearchSubmitted: onSearchSubmitted,
              onDelete: onDelete,
            );
          }

          return const HomeShimmerView();
        },
      ),
    );
  }
}
