import 'package:bloc_todo/core/utils/date_time_helper.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    this.onCompletedChanged,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final TodoModel todo;
  final Future<void> Function(TodoModel todo, bool? value)? onCompletedChanged;
  final VoidCallback? onTap;
  final Function(int id)? onEdit;
  final Function(int id)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Checkbox(
                value: todo.isCompleted,
                onChanged: (value) async {
                  await onCompletedChanged?.call(todo, value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title ?? 'Unknown Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: todo.isCompleted ?? false
                            ? AppColors.textTertiary
                            : AppColors.primary,
                        decoration: todo.isCompleted ?? false
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      todo.priority?.name.toUpperCase() ?? 'UNKNOWN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _SmallInfo(
                          icon: Icons.calendar_today_outlined,
                          label: todo.dueDate == null
                              ? 'No due date'
                              : DateTimeHelper.formatDateTime(
                                  todo.dueDate!,
                                  format: 'dd/MM/yyyy',
                                ),
                        ),
                        const SizedBox(width: 12),
                        _SmallInfo(
                          icon: Icons.flag_outlined,
                          label: todo.isCompleted ?? false
                              ? 'Completed'
                              : 'Pending',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CustomPopup(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PopUpMenuItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTao: () {
                        Navigator.of(context).pop();
                        onEdit?.call(todo.id ?? 0);
                      },
                    ),
                    _PopUpMenuItem(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onTao: () {
                        Navigator.of(context).pop();
                        onDelete?.call(todo.id ?? 0);
                      },
                    ),
                  ],
                ),
                child: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopUpMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function()? onTao;
  const _PopUpMenuItem({required this.icon, required this.label, this.onTao});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: TextButton.icon(
        onPressed: () {
          onTao?.call();
        },
        style: TextButton.styleFrom(
          padding: .zero,
          alignment: .centerStart,
          iconColor: AppColors.primary,
          textStyle: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
