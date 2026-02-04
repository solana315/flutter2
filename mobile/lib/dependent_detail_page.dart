import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/dependent.dart';

// Página de detalhe simples (placeholder)
class DependentDetailPage extends StatelessWidget {
  final Dependent dependent;

  const DependentDetailPage({super.key, required this.dependent});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

<<<<<<< HEAD
    // Use the same palette as menu.dart
=======
    // Use the same palette as Menu.dart
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
    final bg = const Color(0xFFFAF7F4);
    final cardBg = Colors.white;
    final primaryGold = const Color(0xFFA87B05);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Detalhe do dependente'),
        backgroundColor: cardBg,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: cardBg,
<<<<<<< HEAD
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
=======
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: primaryGold,
                          child: Text(
                            _initials(dependent.name),
<<<<<<< HEAD
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
=======
                            style: textTheme.titleLarge?.copyWith(color: Colors.white),
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(dependent.name, style: textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(dependent.relation, style: textTheme.titleMedium),
                      const SizedBox(height: 8),
<<<<<<< HEAD
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
=======
                      Text('Idade: ${dependent.ageOrDob}', style: textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      Text('Página de detalhe (placeholder).', style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Aqui podem ir histórico clínico, contactos, documentos, etc.', style: textTheme.bodyMedium),
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
                    ],
                  ),
                ),
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
