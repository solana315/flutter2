import 'package:flutter/material.dart';

import '../../pages/declarations_docs_page.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Bem-vindo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Dashboard Cards Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Consultas Agendadas
              _DashboardCard(
                icon: Icons.calendar_today,
                title: 'Consultas Agendadas',
                subtitle: 'Veja próximas datas',
                onTap: () {
                  // FALTA: Navegar para consultas agendadas
                },
              ),

              // Planos de Tratamento
              _DashboardCard(
                icon: Icons.medical_services,
                title: 'Planos de Tratamento',
                subtitle: 'Acompanhe etapas',
                onTap: () {
                  // FALTA: Navegar para planos de tratamento
                },
              ),

              // Dependentes
              _DashboardCard(
                icon: Icons.people,
                title: 'Dependentes',
                subtitle: 'Gerir familiares',
                onTap: () {
                  // FALTA: Navegar para dependentes
                },
              ),

              // Declarações/Docs
              _DashboardCard(
                icon: Icons.description,
                title: 'Declarações/Docs',
                subtitle: 'Descarregar comprovante',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeclarationsDocsPage(),
                    ),
                  );
                },
              ),

              // Perfil
              _DashboardCard(
                icon: Icons.person,
                title: 'Perfil',
                subtitle: 'Dados e segurança',
                onTap: () {
                  // FALTA: Navegar para perfil
                },
              ),

              // Contactar Clínica
              _DashboardCard(
                icon: Icons.message,
                title: 'Contactar Clínica',
                subtitle: 'Envie mensagem',
                onTap: () {
                  // FALTA: Navegar para contactar clínica
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
