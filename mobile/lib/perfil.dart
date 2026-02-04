import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api/api_client.dart';
import 'app/session_scope.dart';
import 'widgets/app/app_scaffold.dart';
import 'widgets/app_bottom_nav.dart';
import 'login_page.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
<<<<<<< HEAD
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
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
    final json = await session.patientApi.getProfile(patientId);
    final paciente = (json['paciente'] is Map)
        ? (json['paciente'] as Map).cast<String, dynamic>()
        : json;
    return paciente;
  }

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 3;
    final session = SessionScope.of(context);
    final user = session.user;

    const cardRadius = 12.0;

    return AppScaffold(
      title: 'O meu Perfil',
      actions: [
        IconButton(
          tooltip: 'Definições',
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      bottomNavigationBar: const AppBottomNav(selectedIndex: currentIndex),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dados Pessoais',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Revise e mantenha a sua informação atualizada',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Primary user card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
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
                      message: 'Não foi possível carregar o perfil.',
                      details: err?.toString(),
                      onRetry: () {
                        setState(() {
                          _handledAuthError = false;
                          _future = _load();
                        });
                      },
                    );
                  }

                  final paciente = snapshot.data ?? <String, dynamic>{};

                  final nome = _firstString(paciente, ['nome']) ?? user?.nome;
                  final email =
                      _firstString(paciente, ['email']) ?? user?.email;
                  final telefone = _firstString(paciente, ['telefone']);
                  final sexo = _firstString(paciente, ['sexo']);
                  final endereco = _firstString(paciente, ['endereco']);
                  final nif = _firstString(paciente, ['nif']);
                  final dataNascimento = _formatDate(
                    _firstString(paciente, ['data_nascimento']),
                  );
                  final numeroUtente = _firstString(paciente, [
                    'numero_utente',
                  ]);

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
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            await session.logout();
                            if (!mounted) return;
                            navigator.pushNamedAndRemoveUntil(
                              '/login',
                              (r) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Terminar sessão'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
=======
  Widget build(BuildContext context) {
    final bg = Color.fromARGB(255, 255, 255, 255);
    const int currentIndex = 3;

    const cardRadius = 12.0;

    Widget infoRow(IconData icon, String title, String subtitle) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF3F0EB), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: const Color(0xFFEFFAF1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.person, color: Color(0xFFA87B05), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('O meu Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Dados Pessoais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Revise e mantenha a sua informação atualizada', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),

              // Primary user card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Joana Martins', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF3EDE7), borderRadius: BorderRadius.circular(20)),
                          child: Row(children: const [Icon(Icons.email, size: 14), SizedBox(width: 8), Text('joana.martins@example.com')]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFF3F0EB), borderRadius: BorderRadius.circular(20)),
                        child: Row(children: const [Icon(Icons.phone, size: 14), SizedBox(width: 8), Text('+351 912 345 678')]),
                      ),
                    ]),
                  ],
                ),
              ),

              // Information sections
              infoRow(Icons.email_outlined, 'E-mail', 'joana.martins@example.com'),
              infoRow(Icons.phone_outlined, 'Telefone', '+351 912 345 678'),
              infoRow(Icons.cake_outlined, 'Data de Nascimento', '14 Março 1992'),

              // RGPD & Consentimentos
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(cardRadius), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RGPD e Consentimentos', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF3F0EB), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.description_outlined, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Tratamento de Dados', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(height:4), Text('Consentimento dado em 10 Jan 2024', style: TextStyle(color: Colors.black54))])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF3F0EB), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_outlined, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Imagens Clínicas', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(height:4), Text('Autorizado para registo clínico', style: TextStyle(color: Colors.black54))])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF3F0EB), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.sms_outlined, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Comunicações', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(height:4), Text('SMS e E-mail sobre consultas', style: TextStyle(color: Colors.black54))])),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF6D0D0),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Terminar Sessão', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
        ),
      ),
    );
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json[key];
      if (v == null) continue;
      final s = v.toString();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static String _display(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? '—' : v;
  }

  static String? _formatDate(String? raw) {
    final v = raw?.trim();
    if (v == null || v.isEmpty) return null;
    final parsed = DateTime.tryParse(v);
    if (parsed == null) return v;
    return DateFormat('dd/MM/yyyy').format(parsed);
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
