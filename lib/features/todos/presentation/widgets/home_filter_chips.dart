import 'package:flutter/material.dart';

class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChipItem(
          label: 'All',
          selected: true,
          onTap: () {
            // TODO: Filter all
          },
        ),
        const SizedBox(width: 10),
        _FilterChipItem(
          label: 'Active',
          selected: false,
          onTap: () {
            // TODO: Filter active
          },
        ),
        const SizedBox(width: 10),
        _FilterChipItem(
          label: 'Done',
          selected: false,
          onTap: () {
            // TODO: Filter completed
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
