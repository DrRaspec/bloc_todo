import 'package:bloc_todo/app/routes/app_routes.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_filter_chips.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_header.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_search_box.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_summary_card.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/todo_card.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.todos,
    required this.scrollController,
    this.onCompletedChanged,
  });

  final List<TodoModel> todos;
  final ScrollController scrollController;
  final Future<void> Function(TodoModel todo, bool? value)? onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final createdTodo = await context.push<TodoModel>(
            AppRoutes.createTodo,
          );

          if (createdTodo != null && context.mounted) {
            context.read<TodoCubit>().loadTodos();
          }
        },
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(child: HomeHeader()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: HomeSummaryCard(todos: todos)),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(child: HomeSearchBox()),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(child: HomeFilterChips()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
              sliver: todos.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyTodoList())
                  : SliverList.separated(
                      itemCount: todos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return TodoCard(
                          todo: todos[index],
                          onCompletedChanged: onCompletedChanged,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTodoList extends StatelessWidget {
  const _EmptyTodoList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No todos yet',
          style: TextStyle(fontSize: 16, color: Color(0xFF777777)),
        ),
      ),
    );
  }
}
