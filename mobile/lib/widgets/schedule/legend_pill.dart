import 'package:flutter/material.dart';
import 'schedule_models.dart';

class LegendPill extends StatelessWidget {
  final String label;
  final SlotStatus kind;

  const LegendPill({super.key, required this.label, required this.kind});

  Color _bg() {
    switch (kind) {
      case SlotStatus.available:
        return const Color(0xFFE4F3EA);
      case SlotStatus.unavailable:
        return const Color(0xFFE6E6E6);
    }
  }

  Color _fg(BuildContext context) {
    switch (kind) {
      case SlotStatus.available:
        return Theme.of(context).colorScheme.primary;
      case SlotStatus.unavailable:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _fg(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
