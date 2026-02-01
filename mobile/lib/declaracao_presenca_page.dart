import 'package:flutter/material.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Planos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Declarações',
          ),
        ],
      ),
    );
  }
}
