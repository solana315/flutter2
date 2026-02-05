import 'package:flutter/material.dart';

import '../app/session_controller.dart';
import '../app/session_scope.dart';
import '../api/api_client.dart';
import 'models.dart';
import 'repository.dart';
import 'treatment_plan_detail_page.dart';
import 'widgets.dart';

enum _Segment { todos, meus, dependentes }

class TreatmentPlansPage extends StatefulWidget {
  const TreatmentPlansPage({super.key});

  @override
  State<TreatmentPlansPage> createState() => _TreatmentPlansPageState();
}

class _TreatmentPlansPageState extends State<TreatmentPlansPage> {
  late final _Controller _c;
  bool _handledAuthError = false;

  @override
  void initState() {
    super.initState();
    _c = _Controller();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _c.load(SessionScope.of(context));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
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
        title: const Text('Tratamentos'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final error = _c.error;
            if (error is ApiException) {
              final status = error.status;
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
              }
            }

            return RefreshIndicator(
              onRefresh: () async {
                _handledAuthError = false;
                await _c.refresh(SessionScope.of(context));
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    'Tratamentos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Planos de tratamento para si e dependentes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _SearchField(
                    value: _c.query,
                    onChanged: _c.setQuery,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: _c.segment == _Segment.todos,
                        onSelected: (_) => _c.setSegment(_Segment.todos),
                      ),
                      ChoiceChip(
                        label: const Text('Meus'),
                        selected: _c.segment == _Segment.meus,
                        onSelected: (_) => _c.setSegment(_Segment.meus),
                      ),
                      ChoiceChip(
                        label: const Text('Dependentes'),
                        selected: _c.segment == _Segment.dependentes,
                        onSelected: (_) => _c.setSegment(_Segment.dependentes),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilterChip(
                        label: const Text('Ativo'),
                        selected: _c.statuses.contains('ativo'),
                        onSelected: (_) => _c.toggleStatus('ativo'),
                      ),
                      FilterChip(
                        label: const Text('Pausado'),
                        selected: _c.statuses.contains('pausado'),
                        onSelected: (_) => _c.toggleStatus('pausado'),
                      ),
                      FilterChip(
                        label: const Text('Concluído'),
                        selected: _c.statuses.contains('concluido'),
                        onSelected: (_) => _c.toggleStatus('concluido'),
                      ),
                      FilterChip(
                        label: const Text('Cancelado'),
                        selected: _c.statuses.contains('cancelado'),
                        onSelected: (_) => _c.toggleStatus('cancelado'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_c.loading)
                    const PlansSkeletonList()
                  else if (_c.error != null)
                    _ErrorState(
                      message: 'Não foi possível carregar os planos.',
                      details: _c.error.toString(),
                      onRetry: () => _c.load(SessionScope.of(context)),
                    )
                  else if (_c.filtered.isEmpty)
                    const _EmptyState()
                  else
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _c.filtered.length,
                      itemBuilder: (context, i) {
                        final p = _c.filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlanCard(
                            plan: p,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TreatmentPlanDetailPage(plan: p),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Pesquisar por nome, descrição, ID ou dependente',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        isDense: true,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          const Icon(Icons.folder_off_outlined, size: 34, color: Colors.black54),
          const SizedBox(height: 10),
          Text(
            'Sem planos de tratamento',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Fale com a clínica se esperava ver planos aqui.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String details;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.details, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
    );
  }
}

class _Controller extends ChangeNotifier {
  bool loading = false;
  Object? error;

  List<PlanSummary> _all = const [];
  List<PlanSummary> filtered = const [];

  String query = '';
  _Segment segment = _Segment.todos;
  final Set<String> statuses = <String>{};

  Future<void> load(SessionController session) async {
    final patientId = session.patientId;
    if (patientId == null) {
      error = Exception('Sessão inválida.');
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final repo = TreatmentPlansRepository(session.patientApi);
      _all = await repo.listPlans(patientId);
      _apply();
    } catch (e) {
      error = e;
      _all = const [];
      filtered = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(SessionController session) => load(session);

  void setQuery(String v) {
    query = v;
    _apply();
    notifyListeners();
  }

  void setSegment(_Segment s) {
    segment = s;
    _apply();
    notifyListeners();
  }

  void toggleStatus(String status) {
    if (statuses.contains(status)) {
      statuses.remove(status);
    } else {
      statuses.add(status);
    }
    _apply();
    notifyListeners();
  }

  void _apply() {
    final q = query.trim().toLowerCase();

    Iterable<PlanSummary> it = _all;

    if (segment == _Segment.meus) {
      it = it.where((p) => !p.isDependent);
    } else if (segment == _Segment.dependentes) {
      it = it.where((p) => p.isDependent);
    }

    if (statuses.isNotEmpty) {
      it = it.where((p) => statuses.contains(normalizeStatus(p.status)));
    }

    if (q.isNotEmpty) {
      it = it.where((p) {
        final id = p.idTratamento.toString();
        final nome = (p.nome ?? '').toLowerCase();
        final desc = (p.descricao ?? '').toLowerCase();
        final dep = (p.dependenteNome ?? '').toLowerCase();
        return id.contains(q) || nome.contains(q) || desc.contains(q) || dep.contains(q);
      });
    }

    filtered = it.toList(growable: false);
  }
}
