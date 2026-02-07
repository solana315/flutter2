import 'package:flutter/material.dart';

import 'widgets/declaracao/declaracao_bottom_nav.dart';

class DeclaracaoPresencaPage extends StatefulWidget {
  const DeclaracaoPresencaPage({super.key});

  @override
  State<DeclaracaoPresencaPage> createState() =>
      _DeclaracaoPresencaPageState();
}

class _DeclaracaoPresencaPageState extends State<DeclaracaoPresencaPage> {
  int _selectedIndex = 3;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Implementar navegação conforme necessário
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Declaração de presença'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              
            ],
          ),
        ),
      ),
      bottomNavigationBar: DeclaracaoBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
