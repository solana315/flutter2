import 'package:flutter/material.dart';
//DETALHES

class PlanDetails extends StatelessWidget {
  final Color primaryGold;

  const PlanDetails({super.key, required this.primaryGold});

  @override
  Widget build(BuildContext context) {
    final cardBg = Colors.white;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
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
          Row(
            children: [
              Expanded(child: _detailInfo('Responsável:', 'Dr. Miguel Torres')),
              const SizedBox(width: 8),
              _pill('# 12 sessões', primaryGold, isActive: true),
            ],
          ),
          const SizedBox(height: 12),
          _sectionTitle('Objetivos'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Corrigir apinhamento e melhorar oclusão\nClasse I',
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle('Terapias'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Alinhadores sequenciais, ajustes oclusais, contenções.',
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle('Materiais'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Alinhadores termoplásticos, attachments, elásticos intermaxilares.',
            ),
          ),
          const SizedBox(height: 10),
          _sectionTitle('Recomendações'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Uso 22h/dia, higiene oral rigorosa, check-ups quinzenais.',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA87B05),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text('Agendar próxima sessão'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _pill(String text, Color color, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF3EDE7)
            : const Color.fromARGB(
                255,
                255,
                255,
                255,
              ).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? color : Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
}
