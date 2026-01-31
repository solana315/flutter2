import 'package:flutter/material.dart';
//REGISTOS

class PlanList extends StatelessWidget {
  final Color primaryGold;

  const PlanList({super.key, required this.primaryGold});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _planCard(
          title: 'Ortodontia - Alinhadores',
          doctor: 'Dr. Miguel Torres',
          sessions: '12 sessões',
          status: 'Ativo',
          isActive: true,
        ),
        const SizedBox(height: 12),
        _planCard(
          title: 'Implantologia - 2 Implantes',
          doctor: 'Dra. Inês Carvalho',
          sessions: '6 sessões',
          status: 'Ativo',
          isActive: true,
        ),
        const SizedBox(height: 12),
        _planCard(
          title: 'Reabilitação Estética',
          doctor: 'Dra. Sofia Lima',
          sessions: '4 sessões',
          status: 'Concluído',
          isActive: false,
        ),
      ],
    );
  }

  Widget _planCard({required String title, required String doctor, required String sessions, required String status, required bool isActive}) {
    final cardBg = Colors.white;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: const Color(0x0F000000), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: const Color(0xFFF3EDE7), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.folder_open_outlined, color: Color(0xFFA87B05)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(child: Text(doctor, style: const TextStyle(color: Colors.black54))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(8)),
                      child: Text(sessions, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFEFF7EE) : Colors.grey.withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: isActive ? const Color(0xFF1E7A31) : Colors.black54, fontSize: 12)),
              ),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right_outlined, color: Colors.black38),
            ],
          ),
        ],
      ),
    );
  }
}
