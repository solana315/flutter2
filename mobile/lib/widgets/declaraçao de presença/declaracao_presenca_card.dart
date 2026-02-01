import 'package:flutter/material.dart';

class DeclaracaoPresencaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dataFormatada =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5EFE7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Logo/Ícone
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFB8A876),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                'm.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFB8A876),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // Texto da declaração
          Text(
            'Eu, [Nome Completo], portador(a) do documento de identificação n° [RG/Passaporte], esteve presente na Clinimolestis, hoje, para o atendimento e consulto/tratamento dentário nas instalações referidas anteriormente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24),
          Divider(
            color: Color(0xFFB8A876).withOpacity(0.3),
            thickness: 1,
          ),
          SizedBox(height: 20),
          // Texto adicional
          Text(
            'A presente declaração a título posterior fins de justificação de presença do sujeito, tal como acompanhante de acompanhante dependente ou paciente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24),
          // Data
          Text(
            'Clinimolestis, $dataFormatada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
