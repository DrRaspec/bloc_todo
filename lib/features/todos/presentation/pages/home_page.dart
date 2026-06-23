import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_state.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_shimmer_view.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

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
            );
          }

          if (state is TodoError) {
            return Center(child: Text(state.message));
          }

          if (state is TodoLoaded) {
            return HomeView(
              todos: state.todos,
              scrollController: _scrollController,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
