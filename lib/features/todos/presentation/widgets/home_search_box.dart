import 'package:bloc_todo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeSearchBox extends StatelessWidget {
  final Function(String)? onSearchSubmitted;
  const HomeSearchBox({super.key, this.onSearchSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (value) {
        onSearchSubmitted?.call(value);
      },
      decoration: InputDecoration(
        hintText: 'Search task',
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
