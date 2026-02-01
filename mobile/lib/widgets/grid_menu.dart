import 'package:flutter/material.dart';

class GridMenu extends StatelessWidget {
  const GridMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.78,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _menuCard(
          context: context,
          icon: Icons.calendar_today_outlined,
          title: 'Consultas Agendadas',
          subtitle: 'Veja próximas datas',
          onTap: () {
            Navigator.pushNamed(context, '/asminhasconsultas');
          },
        ),
        _menuCard(
          context: context,
          icon: Icons.medical_services_outlined,
          title: 'Planos de Tratamento',
          subtitle: 'Acompanhe etapas',
          onTap: () {
            Navigator.pushNamed(context, '/plano_tratamento');
          },
        ),
        _menuCard(
          context: context,
          icon: Icons.people_outline,
          title: 'Dependentes',
          subtitle: 'Gerir familiares',
        ),
        _menuCard(
          context: context,
          icon: Icons.description_outlined,
          title: 'Declarações/Docs',
          subtitle: 'Descarregar comprov.',
          onTap: () {
            Navigator.pushNamed(context, '/declaracao');
          },
        ),
        _menuCard(
          context: context,
          icon: Icons.person_outline,
          title: 'Perfil',
          subtitle: 'Dados e segurança',
          onTap: () {
            Navigator.pushNamed(context, '/perfil');
          },
        ),
        _menuCard(
          context: context,
          icon: Icons.mail_outline,
          title: 'Contactar Clínica',
          subtitle: 'Envie uma mensagem',
        ),
      ],
    );
  }
}

Widget _menuCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black54, size: 18),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
