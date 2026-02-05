import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../app/session_scope.dart';

class ConsultaDetailsPage extends StatefulWidget {
  final int consultaId;
  final Map<String, dynamic>? initialConsulta;

  const ConsultaDetailsPage({
    super.key,
    required this.consultaId,
    this.initialConsulta,
  });

  @override
  State<ConsultaDetailsPage> createState() => _ConsultaDetailsPageState();
}

class _ConsultaDetailsPageState extends State<ConsultaDetailsPage> {
  Future<Map<String, dynamic>>? _future;
  bool _handledAuthError = false;

  @override
  void initState() {
    super.initState();
    // Needs context from SessionScope; delay until first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _future ??= _load();
      });
    });
  }

  Future<Map<String, dynamic>> _load() async {
    final session = SessionScope.of(context);
    final patientId = session.patientId;
    if (patientId == null) throw Exception('Sessão inválida.');

    final json = await session.patientApi.getConsulta(patientId, widget.consultaId);
    final consulta = (json['consulta'] is Map)
        ? (json['consulta'] as Map).cast<String, dynamic>()
        : json;
    return consulta;
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFAF7F4);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Detalhes da Consulta'),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final err = snapshot.error;
              final status = (err is ApiException) ? err.status : null;

              if (status == 404 && widget.initialConsulta != null) {
                final consulta = widget.initialConsulta!;
                return _ConsultaDetailsBody(
                  consulta: consulta,
                  showFallbackNote: true,
                );
              }

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

              final message = switch (status) {
                404 => 'Consulta não encontrada.',
                _ => 'Não foi possível carregar a consulta.',
              };

              return _ErrorView(
                message: message,
                details: err?.toString(),
                onRetry: () => setState(() => _future = _load()),
              );
            }

            final consulta = snapshot.data ?? <String, dynamic>{};
            return _ConsultaDetailsBody(consulta: consulta);
          },
        ),
      ),
    );
  }
}

class _ConsultaDetailsBody extends StatelessWidget {
  final Map<String, dynamic> consulta;
  final bool showFallbackNote;

  const _ConsultaDetailsBody({
    required this.consulta,
    this.showFallbackNote = false,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final status = _firstString(consulta, ['status', 'estado']) ?? '—';

    final paciente = _firstString(consulta, ['dependente_nome', 'dependent_name']) ??
        _firstString(consulta, ['paciente_nome', 'patient_name']) ??
        session.user?.nome ??
        '—';

    final profissional = _firstString(consulta, ['medico_nome', 'doctor_name']) ??
        _firstString(consulta, ['id_medico', 'doctor_id']) ??
        '—';

    final especialidade = _firstString(consulta, [
          'especialidade',
          'especialidade_nome',
          'specialty',
          'specialty_name',
        ]) ??
        '—';

    final dataConsulta = _formatDatePt(_firstString(consulta, [
      'data_consulta',
      'data',
      'date',
      'datetime',
      'dataHora',
    ]));

    final hora = _formatHour(_firstString(consulta, ['hora', 'time']));

    final duracao = _formatDurationMinutes(consulta['duracao'] ?? consulta['duracao_minutos']);

    final tipo = _firstString(consulta, ['tipo_de_marcacao', 'tipo', 'type']) ?? '—';
    final motivo = _firstString(consulta, ['razao_consulta', 'motivo', 'reason']) ?? '—';
    final notas = _firstString(consulta, ['notas_internas', 'notas', 'internal_notes']) ?? '—';

    final badge = _statusBadge(status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if (showFallbackNote)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'A mostrar informação do resumo (o servidor devolveu 404).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ),
        _DetailsCard(
          statusText: status,
          statusBg: badge.bg,
          statusFg: badge.fg,
          rows: [
            _RowData('Paciente', paciente),
            _RowData('Profissional', profissional),
            _RowData('Especialidade', especialidade),
            _RowData('Data', dataConsulta ?? '—'),
            _RowData('Hora', hora ?? '—'),
            _RowData('Duração', duracao ?? '—'),
            _RowData('Tipo', tipo),
            _RowData('Motivo', motivo),
            _RowData('Notas internas', notas),
          ],
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final List<_RowData> rows;
  final String statusText;
  final Color statusBg;
  final Color statusFg;

  const _DetailsCard({
    required this.rows,
    required this.statusText,
    required this.statusBg,
    required this.statusFg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes da Consulta',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Informação principal e estado',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(text: statusText, bg: statusBg, fg: statusFg),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            for (int i = 0; i < rows.length; i++) ...[
              _KeyValueLine(label: rows[i].label, value: rows[i].value),
              if (i != rows.length - 1) const Divider(height: 1),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RowData {
  final String label;
  final String value;
  const _RowData(this.label, this.value);
}

class _KeyValueLine extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Text(
              value.trim().isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _StatusBadge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.30)),
      ),
      child: Text(
        text.isEmpty ? '—' : text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.details,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            if (details != null && details!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
            ),
          ],
        ),
      ),
    );
  }
}

String? _firstString(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

String? _formatDatePt(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim();
  DateTime? dt = DateTime.tryParse(s);
  // Some backends send "YYYY-MM-DD HH:mm:ss" (space instead of 'T').
  dt ??= DateTime.tryParse(s.replaceFirst(' ', 'T'));
  if (dt == null) return s;
  return DateFormat('dd/MM/yyyy').format(dt);
}

String? _formatHour(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim();
  // Normalize "09:00:00" -> "09:00".
  if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(s)) {
    return s.substring(0, 5);
  }
  if (RegExp(r'^\d{2}:\d{2}$').hasMatch(s)) return s;
  return s;
}

String? _formatDurationMinutes(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return '${raw.toInt()} min';
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
  if (n == null) return s;
  return '$n min';
}

({Color bg, Color fg}) _statusBadge(String status) {
  final s = status.trim().toLowerCase();
  if (s.contains('confirm')) {
    return (bg: const Color(0xFFE7F8ED), fg: const Color(0xFF1B7F3A));
  }
  if (s.contains('pend')) {
    return (bg: const Color(0xFFFFF4D6), fg: const Color(0xFF8A6A00));
  }
  if (s.contains('cancel') || s.contains('rejeit') || s.contains('recus')) {
    return (bg: const Color(0xFFFFE8E8), fg: const Color(0xFFB42318));
  }
  // Default neutral.
  return (bg: const Color(0xFFEFF4FF), fg: const Color(0xFF2F5BEA));
}
