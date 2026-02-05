import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../app/session_scope.dart';
import '../widgets/app/app_scaffold.dart';
import '../widgets/app/app_card.dart';
import '../widgets/app/app_button.dart'; // Optional if used
import 'dependent_profile_page.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  Future<Map<String, dynamic>>? _future;
  bool _handledAuthError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final session = SessionScope.of(context);
    final patientId = session.patientId;
    if (patientId == null) {
      throw Exception('Sessão inválida. Faça login novamente.');
    }
    final json = await session.patientApi.listDependents(patientId);
    return json;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dependentes',
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = _load();
          });
          await _future;
        },
        child: FutureBuilder<Map<String, dynamic>>(
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

              return _ErrorView(
                error: snapshot.error,
                onRetry: () => setState(() {
                  _handledAuthError = false;
                  _future = _load();
                }),
              );
            }

            final json = snapshot.data ?? <String, dynamic>{};
            final list = _extractList(json);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Text(
                  'Os seus dependentes associados',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 14),
                if (list.isEmpty)
                  _EmptyCard(text: 'Sem dependentes.')
                else
                  _DependentsCard(
                    items: list,
                    onView: (item) => _openDependentProfile(item),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openDependentProfile(Map<String, dynamic> item) {
    final id = _dependentId(item);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir: ID do dependente em falta.'),
        ),
      );
      return;
    }

    final nome = _firstString(item, ['nome', 'name', 'paciente_nome']);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DependentProfilePage(
          dependentId: id,
          dependentName: nome,
          initialItem: item,
        ),
      ),
    );
  }

  static List<Map<String, dynamic>> _extractList(Map<String, dynamic> json) {
    List<Map<String, dynamic>> asMapList(Object? v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
      if (v is Map) {
        final m = v.cast<String, dynamic>();
        // common nested shapes: { items: [...] } or { data: [...] }
        for (final k in const ['dependents', 'dependentes', 'items', 'data']) {
          final nested = m[k];
          if (nested is List) {
            return nested
                .whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList();
          }
        }
      }
      return const <Map<String, dynamic>>[];
    }

    for (final k in const [
      'dependents',
      'dependentes',
      'data',
      'items',
      'result',
      'results',
    ]) {
      final out = asMapList(json[k]);
      if (out.isNotEmpty) return out;
    }

    // Fallback: scan first-level values for a list.
    for (final v in json.values) {
      final out = asMapList(v);
      if (out.isNotEmpty) return out;
    }

    return const <Map<String, dynamic>>[];
  }
}

int? _dependentId(Map<String, dynamic> item) {
  final direct = _asInt(
    item['id'] ??
        item['dependent_id'] ??
        item['dependente_id'] ??
        item['id_dependente'] ??
        item['idDependente'] ??
        item['dependentId'] ??
        item['dependenteId'] ??
        item['patient_id'] ??
        item['id_paciente'] ??
        item['idPaciente'],
  );
  if (direct != null) return direct;

  final nested = (item['dependent'] is Map)
      ? (item['dependent'] as Map).cast<String, dynamic>()
      : (item['dependente'] is Map)
      ? (item['dependente'] as Map).cast<String, dynamic>()
      : null;
  if (nested == null) return null;

  return _asInt(
    nested['id'] ??
        nested['dependent_id'] ??
        nested['dependente_id'] ??
        nested['id_dependente'] ??
        nested['idDependente'] ??
        nested['dependentId'] ??
        nested['dependenteId'] ??
        nested['patient_id'] ??
        nested['id_paciente'] ??
        nested['idPaciente'],
  );
}

void _onTapViewDependent(
  BuildContext context, {
  required Map<String, dynamic> item,
  required void Function(Map<String, dynamic> item) onView,
}) {
  final id = _dependentId(item);
  if (id == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível abrir: ID do dependente em falta.'),
      ),
    );
    return;
  }
  onView(item);
}

int? _asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '');
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

class _DependentsCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onView;

  const _DependentsCard({required this.items, required this.onView});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          if (isWide) {
            return _DependentsTable(items: items, onView: onView);
          }
          return _DependentsMobileList(items: items, onView: onView);
        },
      ),
    );
  }
}

class _DependentsTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onView;
  const _DependentsTable({required this.items, required this.onView});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('Data nascimento')),
          DataColumn(label: Text('Sexo')),
          DataColumn(label: Text('Ações')),
        ],
        rows: items
            .map((item) {
              final nome =
                  _firstString(item, ['nome', 'name', 'paciente_nome']) ??
                  'Dependente';
              final dataNasc = _formatDate(
                _firstString(item, [
                  'data_nascimento',
                  'dataNascimento',
                  'birth_date',
                  'dob',
                ]),
              );
              final sexo = _firstString(item, ['sexo', 'gender']);

              return DataRow(
                cells: [
                  DataCell(Text(nome)),
                  DataCell(Text(_display(dataNasc))),
                  DataCell(Text(_display(sexo))),
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () => _onTapViewDependent(
                          context,
                          item: item,
                          onView: onView,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFA87B05),
                          side: const BorderSide(color: Color(0xFFA87B05)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Ver'),
                      ),
                    ),
                  ),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _DependentsMobileList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onView;
  const _DependentsMobileList({required this.items, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 18),
          _DependentRow(item: items[i], onView: onView),
        ],
      ],
    );
  }
}

class _DependentRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final void Function(Map<String, dynamic> item) onView;
  const _DependentRow({required this.item, required this.onView});

  @override
  Widget build(BuildContext context) {
    final nome =
        _firstString(item, ['nome', 'name', 'paciente_nome']) ?? 'Dependente';
    final dataNasc = _formatDate(
      _firstString(item, [
        'data_nascimento',
        'dataNascimento',
        'birth_date',
        'dob',
      ]),
    );
    final sexo = _firstString(item, ['sexo', 'gender']);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _MiniField(
                    label: 'Data nascimento',
                    value: _display(dataNasc),
                  ),
                  _MiniField(label: 'Sexo', value: _display(sexo)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () =>
              _onTapViewDependent(context, item: item, onView: onView),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFA87B05),
            side: const BorderSide(color: Color(0xFFA87B05)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Ver'),
        ),
      ],
    );
  }
}

class _MiniField extends StatelessWidget {
  final String label;
  final String value;
  const _MiniField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(child: Text(text, textAlign: TextAlign.center)),
    );
  }
}

String _display(String? v) => (v == null || v.trim().isEmpty) ? '—' : v.trim();

String? _firstString(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return null;
}

String? _formatDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim();
  final dt = DateTime.tryParse(s);
  if (dt == null) return s;
  return DateFormat('yyyy-MM-dd').format(dt);
}
