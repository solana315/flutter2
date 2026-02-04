import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../app/session_scope.dart';
import '../widgets/app/app_scaffold.dart';

class DependentProfilePage extends StatefulWidget {
  final int dependentId;
  final String? dependentName;
  final Map<String, dynamic> initialItem;

  const DependentProfilePage({
    super.key,
    required this.dependentId,
    required this.initialItem,
    this.dependentName,
  });

  @override
  State<DependentProfilePage> createState() => _DependentProfilePageState();
}

class _DependentProfilePageState extends State<DependentProfilePage> {
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
    if (patientId == null) throw Exception('Sessão inválida.');

    try {
      final json = await session.patientApi.getDependent(
        patientId,
        widget.dependentId,
      );
      final data = (json['dependent'] is Map)
          ? (json['dependent'] as Map).cast<String, dynamic>()
          : (json['dependente'] is Map)
          ? (json['dependente'] as Map).cast<String, dynamic>()
          : json;
      return data;
    } catch (e) {
      final status = (e is ApiException) ? e.status : null;
      if (status == 404) {
        // Fallback: still render a page using the list payload.
        return widget.initialItem;
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.dependentName ?? 'Dependente',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    final err = snapshot.error;
                    final status = (err is ApiException) ? err.status : null;
                    if ((status == 401 || status == 403) &&
                        !_handledAuthError) {
                      _handledAuthError = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final session = SessionScope.of(context);
                        final navigator = Navigator.of(context);
                        session.logout().then((_) {
                          if (!mounted) return;
                          navigator.pushNamedAndRemoveUntil(
                            '/login',
                            (r) => false,
                          );
                        });
                      });
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return _ErrorCard(
                      message: 'Não foi possível carregar o dependente.',
                      details: err?.toString(),
                      onRetry: () {
                        setState(() {
                          _handledAuthError = false;
                          _future = _load();
                        });
                      },
                    );
                  }

                  final dep = snapshot.data ?? <String, dynamic>{};

                  final nome =
                      _firstString(dep, ['nome', 'name']) ??
                      widget.dependentName;
                  final email = _firstString(dep, ['email']);
                  final telefone = _firstString(dep, ['telefone', 'phone']);
                  final sexo = _firstString(dep, ['sexo', 'gender']);
                  final endereco = _firstString(dep, ['endereco', 'address']);
                  final nif = _firstString(dep, ['nif']);
                  final numeroUtente = _firstString(dep, [
                    'numero_utente',
                    'numeroUtente',
                  ]);
                  final dataNascimento = _formatDate(
                    _firstString(dep, [
                      'data_nascimento',
                      'dataNascimento',
                      'birth_date',
                      'dob',
                    ]),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('Informações pessoais'),
                      const SizedBox(height: 10),
                      _InfoCard(
                        rows: [
                          _InfoRow('Nome', _display(nome)),
                          _InfoRow('Email', _display(email)),
                          _InfoRow('Telefone', _display(telefone)),
                          _InfoRow('Sexo', _display(sexo)),
                          _InfoRow('Endereço', _display(endereco)),
                          _InfoRow('Data nascimento', _display(dataNascimento)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionTitle('Documentos'),
                      const SizedBox(height: 10),
                      _InfoCard(
                        rows: [
                          _InfoRow('NIF', _display(nif)),
                          _InfoRow('Nº utente', _display(numeroUtente)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _KeyValueRow(label: rows[i].label, value: rows[i].value),
            if (i != rows.length - 1) const Divider(height: 16),
          ],
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.details,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.red.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (details != null && details!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            details!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ),
      ],
    );
  }
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final v = json[key];
    if (v == null) continue;
    final s = v.toString();
    if (s.isNotEmpty) return s;
  }
  return null;
}

String _display(String? value) {
  final v = value?.trim();
  return (v == null || v.isEmpty) ? '—' : v;
}

String? _formatDate(String? raw) {
  final v = raw?.trim();
  if (v == null || v.isEmpty) return null;
  final parsed = DateTime.tryParse(v);
  if (parsed == null) return v;
  return DateFormat('dd/MM/yyyy').format(parsed);
}
