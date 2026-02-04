import 'package:flutter/material.dart';

class AtalhosCard extends StatelessWidget {
  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;

  const AtalhosCard({super.key, this.onFirstTap, this.onSecondTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _quickCard(
          title: 'Consultas Agendadas',
          subtitle: 'Próxima: 12 Nov, 10:00',
          onTap: onFirstTap,
        ),
        const SizedBox(height: 8),
        _quickCard(
          title: 'Plano Atual',
          subtitle: 'Em progresso • 2/5 etapas',
          onTap: onSecondTap,
        ),
      ],
    );
  }

  Widget _quickCard({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
