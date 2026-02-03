import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/session_controller.dart';
import 'app/session_scope.dart';
import 'login_page.dart';
import 'Menu.dart';
import 'marcar_consulta.dart';
import 'treatment_plans/treatment_plans_page.dart';
import 'perfil.dart';
import 'declaracao.dart';
import 'pages/patients_page.dart';
import 'pages/declarations_docs_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return MaterialApp(
      title: 'CliniMolelos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: session.isRestoring
          ? const _Splash()
          : (session.isLoggedIn ? const Menu() : const LoginPage()),
      routes: {
        '/login': (context) => const LoginPage(),
        '/menu': (context) => const Menu(),
        '/asminhasconsultas': (context) => const MarcarConsulta(),
        '/plano_tratamento': (context) => const TreatmentPlansPage(),
        '/perfil': (context) => const Perfil(),
        '/declaracao': (context) => Declaracao(),
        '/declarations_docs': (context) => const DeclarationsDocsPage(),
        '/pacientes': (context) => const PatientsPage(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
