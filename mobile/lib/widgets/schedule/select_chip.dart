import 'package:flutter/material.dart';

class SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedBackground;
  final Color selectedBorderColor;
  final Color unselectedBackground;

  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedBackground,
    required this.selectedBorderColor,
    required this.unselectedBackground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedBackground : unselectedBackground;
    final border = selected ? selectedBorderColor : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1),
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
