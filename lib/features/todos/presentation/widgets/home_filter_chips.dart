import 'package:bloc_todo/shared/enums/todo_filter.dart';
import 'package:flutter/material.dart';

class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({
    super.key,
    this.changeFilter,
    required this.selectedFilterIndex,
  });

  final Future<void> Function(TodoFilter filter)? changeFilter;
  final int selectedFilterIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChipItem(
          label: 'All',
          selected: selectedFilterIndex == 0,
          onTap: () {
            changeFilter?.call(TodoFilter.all);
          },
        ),
        const SizedBox(width: 10),
        _FilterChipItem(
          label: 'Active',
          selected: selectedFilterIndex == 1,
          onTap: () {
            changeFilter?.call(TodoFilter.active);
          },
        ),
        const SizedBox(width: 10),
        _FilterChipItem(
          label: 'Done',
          selected: selectedFilterIndex == 2,
          onTap: () {
            changeFilter?.call(TodoFilter.completed);
          },
        ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: const Color(0xFF111111),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF555555),
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}
