import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/dependent.dart';
import 'package:flutter_application_1/pages/dependent_detail_page.dart';

class DependentsPage extends StatelessWidget {
  const DependentsPage({super.key});

  static final List<Dependent> mockDependents = [
    Dependent(
      id: 'd1',
      name: 'Miguel Silva',
      relation: 'Filho',
      dob: DateTime(2014, 6, 12),
    ),
    Dependent(
      id: 'd2',
      name: 'Sofia Silva',
      relation: 'Filha',
      dob: DateTime(2017, 11, 3),
    ),
    Dependent(
      id: 'd3',
      name: 'Ana Pereira',
      relation: 'Cônjuge',
      dob: DateTime(1988, 2, 24),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFAF7F4);
    final cardBg = Colors.white;
    final primaryGold = const Color(0xFFA87B05);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: cardBg,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.people_outline,
                color: Colors.black54,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Dependentes', style: TextStyle(color: Colors.black87)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close, size: 20, color: Colors.black54),
            tooltip: 'Fechar',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: mockDependents.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final d = mockDependents[index];
                        return DependentCard(
                          dependent: d,
                          cardBg: cardBg,
                          primaryColor: primaryGold,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DependentDetailPage(dependent: d),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DependentCard extends StatelessWidget {
  final Dependent dependent;
  final VoidCallback? onTap;
  final Color? cardBg;
  final Color? primaryColor;

  const DependentCard({
    super.key,
    required this.dependent,
    this.onTap,
    this.cardBg,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: cardBg ?? Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor ?? theme.colorScheme.primary,
                child: Text(
                  _initials(dependent.name),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dependent.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dependent.relation} • ${dependent.ageOrDob}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor ?? const Color(0xFFA87B05)),
                ),
                child: Text(
                  'Ver',
                  style: TextStyle(
                    color: primaryColor ?? const Color(0xFFA87B05),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
