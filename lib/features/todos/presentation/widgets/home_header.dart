import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_bridge/liquid_glass_bridge.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.totalTodos});
  final int totalTodos;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$totalTodos tasks',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        SizedBox.square(
          dimension: 58,
          child: LiquidGlassButton(
            onPressed: () {
              // TODO: Open settings
            },
            // style: IconButton.styleFrom(
            //   backgroundColor: AppColors.surface,
            //   foregroundColor: AppColors.primary,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            // ),
            child: const Icon(Icons.tune_rounded),
          ),
        ),
      ],
    );
  }
}
