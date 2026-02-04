import 'dart:convert';

import 'package:flutter/material.dart';

import 'app/session_scope.dart';
import 'widgets/app/app_scaffold.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/planoTratamento/filter_chips.dart';

class PlanoTratamentoPage extends StatefulWidget {
  const PlanoTratamentoPage({super.key});

  @override
  State<PlanoTratamentoPage> createState() => _PlanoTratamentoPageState();
}

class _PlanoTratamentoPageState extends State<PlanoTratamentoPage> {
  final bg = const Color(0xFFFAF7F4);
  final cardBg = Colors.white;
  final primaryGold = const Color(0xFFA87B05);
  bool showActive = true;
  Future<Map<String, dynamic>>? _future;
  Map<String, dynamic>? _selected;
  Future<Map<String, dynamic>>? _detailsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final session = SessionScope.of(context);
    final userId = session.userId;
    if (userId == null) throw Exception('Sessão inválida.');
    return session.patientApi.listPlanos(userId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Planos de Tratamento',
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(
                  error: snapshot.error,
                  onRetry: () => setState(() => _future = _load()),
                );
              }

              final json = snapshot.data ?? <String, dynamic>{};
              final planos = _extractList(json);
              final filtered = planos
                  .where((p) => _matchesFilter(p, showActive))
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Registo Clínico\nAcompanhe os seus planos, sessões e progresso',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    FilterChips(
                      showActive: showActive,
                      onChanged: (v) => setState(() => showActive = v),
                      primaryGold: primaryGold,
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Sem planos.')),
                      )
                    else
                      ...filtered.map(
                        (p) => _PlanCard(
                          plan: p,
                          primaryGold: primaryGold,
                          selected: identical(p, _selected),
                          onTap: () => _selectPlan(p),
                        ),
                      ),
                    const SizedBox(height: 18),
                    _PlanDetails(
                      primaryGold: primaryGold,
                      detailsFuture: _detailsFuture,
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectPlan(Map<String, dynamic> plan) async {
    setState(() {
      _selected = plan;
      _detailsFuture = _loadDetails(plan);
    });
  }

  Future<Map<String, dynamic>>? _loadDetails(Map<String, dynamic> plan) {
    final session = SessionScope.of(context);
    final userId = session.userId;
    final id = _asInt(plan['id'] ?? plan['id_tratamento'] ?? plan['planoId']);
    if (userId == null || id == null) return null;
    return session.patientApi.getPlano(userId, id);
  }

  static List<Map<String, dynamic>> _extractList(Map<String, dynamic> json) {
    final candidates = [json['planos'], json['data'], json['items']];
    for (final c in candidates) {
      if (c is List) {
        return c
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    }
    return const [];
  }

  static bool _matchesFilter(Map<String, dynamic> plan, bool showActive) {
    final status = (plan['status'] ?? plan['estado'] ?? '')
        .toString()
        .toLowerCase();
    final ativo = plan['ativo'];
    final isActive = (ativo is bool)
        ? ativo
        : !(status.contains('concl') ||
              status.contains('final') ||
              status.contains('inativ'));
    return showActive ? isActive : !isActive;
  }

  static int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final Color primaryGold;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.primaryGold,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = (plan['titulo'] ?? plan['nome'] ?? plan['name'] ?? 'Plano')
        .toString();
    final doctor =
        (plan['doctor'] ?? plan['medico'] ?? plan['responsavel'] ?? '')
            .toString();
    final status = (plan['status'] ?? plan['estado'] ?? '').toString();
    final sessions = (plan['sessoes'] ?? plan['sessions'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? primaryGold.withAlpha((0.30 * 255).round())
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder_open_outlined, color: primaryGold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (doctor.isNotEmpty) doctor,
                          if (sessions.isNotEmpty) sessions,
                          if (status.isNotEmpty) status,
                        ].join(' • '),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_outlined, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanDetails extends StatelessWidget {
  final Color primaryGold;
  final Future<Map<String, dynamic>>? detailsFuture;

  const _PlanDetails({required this.primaryGold, required this.detailsFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0F000000),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Detalhes do Plano',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (detailsFuture == null)
            const Text(
              'Selecione um plano para ver detalhes.',
              style: TextStyle(color: Colors.black54),
            )
          else
            FutureBuilder<Map<String, dynamic>>(
              future: detailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Erro: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  );
                }
                final json = snapshot.data ?? <String, dynamic>{};
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(const JsonEncoder.withIndent('  ').convert(json)),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Erro ao carregar: ${error ?? 'desconhecido'}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
