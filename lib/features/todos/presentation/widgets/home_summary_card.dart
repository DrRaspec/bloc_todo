import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:flutter/material.dart';

class HomeSummaryCard extends StatelessWidget {
  final List<TodoModel> todos;
  const HomeSummaryCard({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final total = todos.length;
    final completed = todos.where((todo) => (todo.isCompleted ?? false)).length;
    double percentage = total > 0 ? (completed / total) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$completed of $total completed',
                  style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 58,
            width: 58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
