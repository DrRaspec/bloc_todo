import 'package:bloc_todo/app/di/injection.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:bloc_todo/core/utils/date_time_helper.dart';
import 'package:bloc_todo/features/todos/domain/repositories/todo_repository.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TodoDetailPage extends StatefulWidget {
  const TodoDetailPage({super.key, required this.todoId});

  final int todoId;

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late final TodoRepository _repository;
  late Future<TodoModel?> _todoFuture;

  @override
  void initState() {
    super.initState();
    _repository = Injection.getIt<TodoRepository>();
    _todoFuture = _repository.getTodoById(widget.todoId);
  }

  Future<void> _toggleCompleted(TodoModel todo) async {
    final updatedTodo = todo.copyWith(
      isCompleted: !(todo.isCompleted ?? false),
    );
    await _repository.updateTodo(updatedTodo);

    if (!mounted) return;

    setState(() {
      _todoFuture = Future.value(updatedTodo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<TodoModel?>(
          future: _todoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _DetailMessage(
                icon: Icons.error_outline_rounded,
                title: 'Could not load todo',
                message: snapshot.error.toString(),
                onBack: context.pop,
              );
            }

            final todo = snapshot.data;
            if (todo == null) {
              return _DetailMessage(
                icon: Icons.search_off_rounded,
                title: 'Todo not found',
                message: 'This todo may have been deleted.',
                onBack: context.pop,
              );
            }

            return _DetailContent(todo: todo, onToggle: _toggleCompleted);
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.todo, required this.onToggle});

  final TodoModel todo;
  final Future<void> Function(TodoModel todo) onToggle;

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.isCompleted ?? false;
    final description = todo.description?.trim();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(true),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                _StatusPill(isCompleted: isCompleted),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              todo.title?.trim().isNotEmpty == true
                  ? todo.title!.trim()
                  : 'Unknown Title',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _InfoGrid(
              children: [
                _InfoTile(
                  icon: Icons.flag_outlined,
                  label: 'Priority',
                  value: todo.priority?.name.toUpperCase() ?? 'UNKNOWN',
                ),
                _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Due date',
                  value: todo.dueDate == null
                      ? 'No due date'
                      : DateTimeHelper.formatDateTime(
                          todo.dueDate!,
                          format: 'dd MMM yyyy',
                        ),
                ),
                _InfoTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Reminder',
                  value: todo.reminderAt == null
                      ? 'No reminder'
                      : DateTimeHelper.formatDateTime(
                          todo.reminderAt!,
                          format: 'dd MMM yyyy, HH:mm',
                        ),
                ),
                _InfoTile(
                  icon: Icons.update_rounded,
                  label: 'Updated',
                  value: todo.updatedAt == null
                      ? 'Not available'
                      : DateTimeHelper.formatDateTime(
                          todo.updatedAt!,
                          format: 'dd MMM yyyy',
                        ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _Section(
              title: 'Description',
              child: Text(
                description?.isNotEmpty == true
                    ? description!
                    : 'No description added.',
                style: TextStyle(
                  color: description?.isNotEmpty == true
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => onToggle(todo),
                icon: Icon(
                  isCompleted
                      ? Icons.radio_button_unchecked_rounded
                      : Icons.check_rounded,
                ),
                label: Text(
                  isCompleted ? 'Mark as active' : 'Mark as completed',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: tileWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success : AppColors.subtleFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'Active',
        style: TextStyle(
          color: isCompleted ? AppColors.surface : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onBack,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 54, color: AppColors.textSecondary),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}
