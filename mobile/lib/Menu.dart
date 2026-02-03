import 'package:flutter/material.dart';
import 'app/session_scope.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/grid_menu.dart';
import 'widgets/menu/atalhosCard.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFAF7F4);
    final cardBg = Colors.white;
    final primaryGold = const Color(0xFFA87B05);
    final session = SessionScope.of(context);
    final nome = session.user?.nome;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset('assets/CliniMolelos.png'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Clinimolelos',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.notifications_none),
                          SizedBox(width: 12),
                          Icon(Icons.help_outline),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // CARD PRINCIPAL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.03),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${nome != null && nome.isNotEmpty ? nome : 'Paciente'}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bem-vindo de volta ao seu espaço de paciente',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/asminhasconsultas');
                            },
                            child: const Text(
                              'Marcar Consulta',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // GRID MENU
                  const GridMenu(),

                  const SizedBox(height: 18),

                  // ATALHOS RÁPIDOS
                  const Text(
                    'Atalhos Rápidos',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  //CARD
                  AtalhosCard(
                    onFirstTap: () {
                      Navigator.pushNamed(context, '/asminhasconsultas');
                    },
                    onSecondTap: () {
                      // ação futura
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
