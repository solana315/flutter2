import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/dependent.dart';
import 'widgets/app/app_card.dart';
import 'widgets/app/app_colors.dart';
import 'widgets/app/app_scaffold.dart';

// Página de detalhe simples (placeholder)
class DependentDetailPage extends StatelessWidget {
  final Dependent dependent;

  const DependentDetailPage({super.key, required this.dependent});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Detalhe do dependente',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: AppCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryGold,
                      child: Text(
                        _initials(dependent.name),
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(dependent.name, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(dependent.relation, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Idade: ${dependent.ageOrDob}',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Página de detalhe (placeholder).',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aqui podem ir histórico clínico, contactos, documentos, etc.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
