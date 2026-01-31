import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/marcar_consulta/dashboard.dart';
import 'widgets/marcar_consulta/topo.dart';

class MarcarConsulta extends StatelessWidget {
  const MarcarConsulta({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFAF7F4);
    const int currentIndex = 1;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopoMarcarConsulta(),
              const Dashboard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(selectedIndex: currentIndex),
    );
  }
}