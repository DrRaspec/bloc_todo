import 'package:bloc_todo/shared/models/todo_model.dart';
import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeSummaryCard extends StatefulWidget {
  final List<TodoModel> todos;
  const HomeSummaryCard({super.key, required this.todos});

  @override
  State<HomeSummaryCard> createState() => _HomeSummaryCardState();
}

class _HomeSummaryCardState extends State<HomeSummaryCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.todos.length;
    final completed = widget.todos
        .where((todo) => (todo.isCompleted ?? false))
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
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
                    color: AppColors.surface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$completed of $total completed',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 58,
            width: 58,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 16,
                sections: showingSections(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    const sections = [
      _PieSectionData(
        color: AppColors.chartBlack,
        labelColor: AppColors.chartTextDark,
        value: 40,
        title: '40%',
      ),
      _PieSectionData(
        color: AppColors.chartDarkGray,
        labelColor: AppColors.chartTextDark,
        value: 30,
        title: '30%',
      ),
      _PieSectionData(
        color: AppColors.chartGray,
        labelColor: AppColors.chartTextLight,
        value: 15,
        title: '15%',
      ),
      _PieSectionData(
        color: AppColors.chartLightGray,
        labelColor: AppColors.chartTextLight,
        value: 15,
        title: '15%',
      ),
    ];

    return List.generate(sections.length, (i) {
      final isTouched = i == touchedIndex;
      final section = sections[i];

      final double fontSize = isTouched ? 13.0 : 11.0;
      final double radius = isTouched ? 38 : 28;

      return PieChartSectionData(
        color: section.color,
        value: section.value,
        title: section.title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: section.labelColor,
        ),
      );
    });
  }
}

class _PieSectionData {
  final Color color;
  final Color labelColor;
  final double value;
  final String title;

  const _PieSectionData({
    required this.color,
    required this.labelColor,
    required this.value,
    required this.title,
  });
}
