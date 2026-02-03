import 'package:flutter/material.dart';

import 'models.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeStatus(status);
    final (fg, label) = switch (normalized) {
      'ativo' => (const Color(0xFF16A34A), 'Ativo'),
      'pausado' => (const Color(0xFFF59E0B), 'Pausado'),
      'concluido' => (Colors.grey, 'Concluído'),
      'cancelado' => (const Color(0xFFEF4444), 'Cancelado'),
      _ => (Colors.grey, status.trim().isEmpty ? '—' : status.trim()),
    };

    final bg = fg.withValues(alpha: 0.12);

    return Semantics(
      label: 'Estado: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fg.withValues(alpha: 0.28)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final PlanSummary plan;
  final VoidCallback onTap;

  const PlanCard({super.key, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final range = _formatDateRange(plan.dataInicio, plan.dataFim);
    final target = plan.isDependent
        ? (plan.dependenteNome == null || plan.dependenteNome!.trim().isEmpty
            ? 'Dependente'
            : plan.dependenteNome!.trim())
        : 'Paciente';

    final desc = (plan.descricao ?? '').trim();
    final showDesc = desc.isNotEmpty && desc != plan.title;

    return Semantics(
      button: true,
      label: 'Plano ${plan.title}. Abrir detalhes.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Plano #${plan.idTratamento}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          StatusChip(status: plan.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        range,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Para: $target',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      if (showDesc) ...[
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black45),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.chevron_right, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final s = formatDatePt(start);
    final e = formatDatePt(end);
    if (s == '—' && e == '—') return '—';
    if (e == '—') return '$s • —';
    if (s == '—') return '— • $e';
    return '$s • $e';
  }
}

class PlansSkeletonList extends StatelessWidget {
  final int itemCount;
  const PlansSkeletonList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surface;
    final shimmer = scheme.surfaceContainerHighest;

    Widget block({double? h, double? w}) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: shimmer,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: block(h: 18)),
                    const SizedBox(width: 12),
                    block(h: 24, w: 70),
                  ],
                ),
                const SizedBox(height: 10),
                block(h: 12, w: 160),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: block(h: 44)),
                    const SizedBox(width: 12),
                    Expanded(child: block(h: 44)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
