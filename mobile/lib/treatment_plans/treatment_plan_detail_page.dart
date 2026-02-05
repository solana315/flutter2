import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../api/api_client.dart';
import '../app/session_scope.dart';
import 'models.dart';
import 'repository.dart';
import 'widgets.dart';

class TreatmentPlanDetailPage extends StatefulWidget {
  final PlanSummary plan;

  const TreatmentPlanDetailPage({super.key, required this.plan});

  @override
  State<TreatmentPlanDetailPage> createState() => _TreatmentPlanDetailPageState();
}

class _TreatmentPlanDetailPageState extends State<TreatmentPlanDetailPage> {
  Future<PlanDetail>? _future;
  bool _handledAuthError = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _future ??= _load();
      });
    });
  }

  Future<PlanDetail> _load() async {
    final session = SessionScope.of(context);
    final patientId = session.patientId;
    if (patientId == null) throw Exception('Sessão inválida.');

    final repo = TreatmentPlansRepository(session.patientApi);
    return repo.getPlanDetail(patientId, widget.plan.idTratamento);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.surfaceContainerLow;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Plano de Tratamento'),
      ),
      body: SafeArea(
        child: FutureBuilder<PlanDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final err = snapshot.error;
              final status = (err is ApiException) ? err.status : null;

              if ((status == 401 || status == 403) && !_handledAuthError) {
                _handledAuthError = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final session = SessionScope.of(context);
                  final navigator = Navigator.of(context);
                  session.logout().then((_) {
                    if (!mounted) return;
                    navigator.pushNamedAndRemoveUntil('/login', (r) => false);
                  });
                });
                return const Center(child: CircularProgressIndicator());
              }

              return _DetailErrorState(
                message: 'Não foi possível carregar o plano.',
                details: err?.toString() ?? '',
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final detail = snapshot.data;
            final plan = detail?.plano ?? widget.plan;

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                  children: [
                    Text(
                      plan.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Plano #${plan.idTratamento}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 10),
                        StatusChip(status: plan.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SectionCard(
                      title: 'Resumo',
                      child: _SummarySection(plan: plan),
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      title: 'Consultas associadas',
                      child: _ConsultasSection(consultas: detail?.consultas ?? const []),
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _downloading ? null : _downloadPdf,
                        child: _downloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Descarregar PDF'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _sanitizeFilename(String name) {
    // Prevent path traversal / invalid separators.
    final cleaned = name
        .replaceAll(RegExp(r'[\\/]+'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? 'plano_${widget.plan.idTratamento}.pdf' : cleaned;
  }

  Future<void> _downloadPdf() async {
    final session = SessionScope.of(context);
    final patientId = session.patientId;
    if (patientId == null) return;

    setState(() => _downloading = true);

    try {
      final repo = TreatmentPlansRepository(session.patientApi);
      final res = await repo.downloadPlanPdf(patientId, widget.plan.idTratamento);

      final dir = await getApplicationDocumentsDirectory();
      final suggested = _sanitizeFilename(
        (res.filename != null && res.filename!.trim().isNotEmpty)
            ? res.filename!.trim()
            : 'plano_${widget.plan.idTratamento}.pdf',
      );

      final file = File('${dir.path}/$suggested');
      await file.writeAsBytes(res.bytes, flush: true);

      if (!mounted) return;

      final openRes = await OpenFilex.open(file.path);
      if (!mounted) return;
      if (openRes.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado em: ${file.path}')),
        );
      }
    } catch (e) {
      if (e is ApiException && (e.status == 401 || e.status == 403)) {
        final navigator = Navigator.of(context);
        await session.logout();
        if (!mounted) return;
        navigator.pushNamedAndRemoveUntil('/login', (r) => false);
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao descarregar PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }
}

class _SummarySection extends StatefulWidget {
  final PlanSummary plan;
  const _SummarySection({required this.plan});

  @override
  State<_SummarySection> createState() => _SummarySectionState();
}

class _SummarySectionState extends State<_SummarySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final plan = widget.plan;

    final target = plan.isDependent
        ? 'Dependente: ${plan.dependenteNome ?? 'Dependente'}'
        : 'Paciente';

    final desc = (plan.descricao ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KeyValue(label: 'Para', value: target),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _KeyValue(label: 'Início', value: formatDatePt(plan.dataInicio)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KeyValue(label: 'Fim', value: formatDatePt(plan.dataFim)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Descrição',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                desc.isEmpty ? '—' : desc,
                maxLines: _expanded ? null : 5,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
              if (desc.length > 220) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(_expanded ? 'Ver menos' : 'Ver mais'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ConsultasSection extends StatelessWidget {
  final List<AssociatedConsulta> consultas;

  const _ConsultasSection({required this.consultas});

  @override
  Widget build(BuildContext context) {
    if (consultas.isEmpty) {
      return const Text('Sem consultas associadas.');
    }

    return Column(
      children: [
        for (int i = 0; i < consultas.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ConsultaMiniCard(c: consultas[i]),
        ],
      ],
    );
  }
}

class _ConsultaMiniCard extends StatelessWidget {
  final AssociatedConsulta c;

  const _ConsultaMiniCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dt = c.dateTime;
    final date = dt == null ? '—' : '${formatDatePt(dt)} • ${TimeOfDay.fromDateTime(dt).format(context)}';
    final doctor = (c.medicoNome ?? '').trim().isEmpty ? '—' : c.medicoNome!.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Médico: $doctor', style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusChip(status: c.status),
        ],
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  final String message;
  final String details;
  final VoidCallback onRetry;

  const _DetailErrorState({required this.message, required this.details, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(details, style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Tentar novamente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
