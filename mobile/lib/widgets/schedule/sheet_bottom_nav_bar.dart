import 'package:flutter/material.dart';

class SheetBottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const SheetBottomNavBar({super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SheetNavItem(
                icon: Icons.home_outlined,
                label: 'Início',
                selected: index == 0,
                onTap: () => onChanged(0),
                active: scheme.primary,
              ),
              SheetNavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Consultas',
                selected: index == 1,
                onTap: () => onChanged(1),
                active: scheme.primary,
              ),
              SheetNavItem(
                icon: Icons.folder_open_outlined,
                label: 'Planos',
                selected: index == 2,
                onTap: () => onChanged(2),
                active: scheme.primary,
              ),
              SheetNavItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                selected: index == 3,
                onTap: () => onChanged(3),
                active: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SheetNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color active;

  const SheetNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? active : Colors.black54;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFF3EDE7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
