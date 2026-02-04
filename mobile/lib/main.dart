import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/session_controller.dart';
import 'app/session_scope.dart';
import 'login_page.dart';
import 'menu.dart';
import 'planotratamento.dart';
import 'perfil.dart';
import 'declaracao.dart';
<<<<<<< HEAD
import 'pages/patients_page.dart';
=======
import 'minhas_consultas_page.dart';
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env (if present)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    debugPrint('No .env file found or error loading env');
  }

  final session = await SessionController.bootstrap();
  runApp(SessionScope(controller: session, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CliniMolelos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/menu': (context) => const Menu(),
        '/asminhasconsultas': (context) => const MarcarConsulta(),
        '/plano_tratamento': (context) => const PlanoTratamentoPage(),
        '/perfil': (context) => Perfil(),
        '/declaracao': (context) => Declaracao(),
        '/pacientes': (context) => const PatientsPage(),
      },
    );
  }
}
=======
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'CliniMolelos',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				primarySwatch: Colors.green,
			),
			home: const LoginPage(),
        routes: {
    '/login': (context) => const LoginPage(),
    '/menu': (context) => const Menu(),
	'/asminhasconsultas': (context) => const MinhasConsultasPage(),
		'/plano_tratamento': (context) => const PlanoTratamentoPage(),
    '/perfil': (context) => Perfil(),
    '/declaracao': (context) => Declaracao(),
  },
		);
	}
}
>>>>>>> c79b55e79eb14f3463c6268bbb1d4a0f249ea436
