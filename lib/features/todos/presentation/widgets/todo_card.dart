import 'package:bloc_todo/core/utils/date_time_helper.dart';
import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.todo});

  final TodoModel todo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) {
              // TODO: Toggle completed
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            activeColor: const Color(0xFF111111),
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
                        ? const Color(0xFF999999)
                        : const Color(0xFF111111),
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
                    color: Color(0xFF888888),
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
          IconButton(
            onPressed: () {
              // TODO: Open detail or edit todo
            },
            icon: const Icon(Icons.more_horiz_rounded),
            color: const Color(0xFF777777),
          ),
        ],
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
        Icon(icon, size: 14, color: const Color(0xFF777777)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF777777),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
