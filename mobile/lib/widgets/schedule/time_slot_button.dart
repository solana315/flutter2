import 'package:flutter/material.dart';
import 'schedule_models.dart';

class TimeSlotButton extends StatelessWidget {
  final String label;
  final SlotStatus status;
  final bool selected;
  final VoidCallback? onTap;

  const TimeSlotButton({
    super.key,
    required this.label,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  Color _bg() {
    switch (status) {
      case SlotStatus.available:
        return const Color(0xFFE4F3EA);
      case SlotStatus.unavailable:
        return const Color(0xFFE6E6E6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = status == SlotStatus.unavailable || onTap == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      selected: selected,
      label: 'Horário $label',
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _bg(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: disabled ? Colors.black38 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
