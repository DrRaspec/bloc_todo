import 'package:bloc_todo/app/routes/app_routes.dart';
import 'package:bloc_todo/core/widgets/app_dialog.dart';
import 'package:bloc_todo/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_filter_chips.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_header.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_search_box.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/home_summary_card.dart';
import 'package:bloc_todo/features/todos/presentation/widgets/todo_card.dart';
import 'package:bloc_todo/shared/enums/todo_filter.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.todos,
    required this.scrollController,
    this.changeFilter,
    this.selectedFilterIndex = 0,
    this.onCompletedChanged,
    this.onDelete,
    this.onSearchSubmitted,
  });

  final List<TodoModel> todos;
  final ScrollController scrollController;
  final Future<void> Function(TodoFilter filter)? changeFilter;
  final int selectedFilterIndex;
  final Future<void> Function(TodoModel todo, bool? value)? onCompletedChanged;
  final Future<void> Function(int id)? onDelete;
  final Future<void> Function(String query)? onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final createdTodo = await context.push<TodoModel>(
            AppRoutes.createTodoPath,
          );

          if (createdTodo != null && context.mounted) {
            context.read<TodoCubit>().loadTodos();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: HomeHeader(totalTodos: todos.length),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(child: HomeSummaryCard(todos: todos)),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: HomeSearchBox(onSearchSubmitted: onSearchSubmitted),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: HomeFilterChips(
                  changeFilter: changeFilter,
                  selectedFilterIndex: selectedFilterIndex,
                ),
              ),
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
                          onTap: () async {
                            final shouldRefresh = await context.push<bool>(
                              AppRoutes.todoDetailPath(todos[index].id ?? 0),
                            );

                            if (shouldRefresh == true && context.mounted) {
                              context.read<TodoCubit>().loadTodos();
                            }
                          },
                          onCompletedChanged: onCompletedChanged,
                          onEdit: (id) async {
                            final updatedTodo = await context.push<TodoModel>(
                              AppRoutes.editTodoPath(id),
                            );

                            if (updatedTodo != null && context.mounted) {
                              context.read<TodoCubit>().loadTodos();
                            }
                          },
                          onDelete: (id) async {
                            AppDialog.showDeleteTodoDialog(
                              context: context,
                              onDelete: (id) async {
                                await onDelete?.call(id);
                              },
                              todoId: id,
                            );
                          },
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No todos yet',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
