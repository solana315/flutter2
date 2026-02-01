import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart';
import 'login_page.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
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
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: currentIndex),
    );
  }
}
