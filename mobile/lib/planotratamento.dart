import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/planoTratamento/filter_chips.dart';
import 'widgets/planoTratamento/plan_list.dart';
import 'widgets/planoTratamento/plan_details.dart';

class PlanoTratamentoPage extends StatefulWidget {
	const PlanoTratamentoPage({super.key});

	@override
	State<PlanoTratamentoPage> createState() => _PlanoTratamentoPageState();
}

class _PlanoTratamentoPageState extends State<PlanoTratamentoPage> {
	final bg = const Color(0xFFFAF7F4);
	final cardBg = Colors.white;
	final primaryGold = const Color(0xFFA87B05);
	bool showActive = true;

	@override
	Widget build(BuildContext context) {
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
											const Text(
												'Planos de Tratamento',
												style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
											),
											IconButton(
												onPressed: () => Navigator.pop(context),
												icon: const Icon(Icons.close),
											),
										],
									),

									const SizedBox(height: 6),

									const Text(
										'Registo Clínico\nAcompanhe os seus planos, sessões e progresso',
										style: TextStyle(color: Colors.black54),
									),

									const SizedBox(height: 12),

									FilterChips(showActive: showActive, onChanged: (v) => setState(() => showActive = v), primaryGold: primaryGold),

									const SizedBox(height: 12),

									// Lista de planos (widget separado)
									PlanList(primaryGold: primaryGold),

									const SizedBox(height: 18),

									// Detalhes do plano (widget separado)
									PlanDetails(primaryGold: primaryGold),

									const SizedBox(height: 18),
								],
							),
						),
					),
				),
			),
			bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
		);
	}

  
}

