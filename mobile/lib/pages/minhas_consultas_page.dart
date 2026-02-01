import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';

class MinhasConsultasPage extends StatefulWidget {
  const MinhasConsultasPage({super.key});

  @override
  State<MinhasConsultasPage> createState() => _MinhasConsultasPageState();
}

class _MinhasConsultasPageState extends State<MinhasConsultasPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCard({required String day, required String month, required String name, required String specialty, required String time, required String weekday, required String status, Color? statusColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFF3F0EB), borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(month, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor ?? Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                      child: Text(status, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(specialty, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(time, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text('$weekday', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.calendar_month, color: Colors.green),
                      ),
                      const SizedBox(width: 12),
                      const Text('Minhas Consultas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Declarações', style: TextStyle(fontWeight: FontWeight.w600)),
                        Icon(Icons.insert_drive_file_outlined, color: Colors.black54),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicator: BoxDecoration(color: const Color(0xFFF3EDE7), borderRadius: BorderRadius.circular(20)),
                      unselectedLabelColor: Colors.black54,
                      tabs: const [Tab(text: 'Futuras'), Tab(text: 'Passadas')],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text('Próximas', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Futuras
                    ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildCard(day: '14', month: 'NOV', name: 'Dra. Sofia Lima', specialty: 'Higiene Oral', time: '10:30', weekday: 'Qui, 14 Nov', status: 'Confirmada', statusColor: Colors.green.shade100),
                        _buildCard(day: '22', month: 'NOV', name: 'Dr. Miguel Torres', specialty: 'Ortodontia', time: '09:00', weekday: 'Sex, 22 Nov', status: 'Pendente', statusColor: Colors.amber.shade100),
                        _buildCard(day: '02', month: 'DEZ', name: 'Dra. Inês Carvalho', specialty: 'Implantologia', time: '15:00', weekday: 'Seg, 02 Dez', status: 'Confirmada', statusColor: Colors.green.shade100),
                        const SizedBox(height: 12),
                        const Text('Histórico', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildCard(day: '28', month: 'OUT', name: 'Dra. Sofia Lima', specialty: 'Higiene Oral', time: '11:30', weekday: 'Seg, 28 Out', status: 'Concluída', statusColor: Colors.blue.shade100),
                        _buildCard(day: '12', month: 'OUT', name: 'Dr. Ricardo Nunes', specialty: 'Cirurgia Oral', time: '14:00', weekday: 'Sáb, 12 Out', status: 'Cancelada', statusColor: Colors.red.shade100),
                      ],
                    ),

                    // Passadas (same demo content)
                    ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildCard(day: '28', month: 'OUT', name: 'Dra. Sofia Lima', specialty: 'Higiene Oral', time: '11:30', weekday: 'Seg, 28 Out', status: 'Concluída', statusColor: Colors.blue.shade100),
                        _buildCard(day: '12', month: 'OUT', name: 'Dr. Ricardo Nunes', specialty: 'Cirurgia Oral', time: '14:00', weekday: 'Sáb, 12 Out', status: 'Cancelada', statusColor: Colors.red.shade100),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }
}
