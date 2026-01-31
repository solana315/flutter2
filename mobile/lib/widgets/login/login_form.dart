import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../menu.dart';
import 'login_fields.dart';
import 'buttons.dart';


//lógica de código do login

class LoginForm extends StatefulWidget {
  final Color bg;
  final Color cardBg;
  final Color loginColor;
  final Color recoverColor;

  const LoginForm({
    super.key,
    required this.bg,
    required this.cardBg,
    required this.loginColor,
    required this.recoverColor,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

//dispose limpa os dados
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

//email textfield é necessário não estar nulo para o login, ou envia a mensagem abaixo
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;
    if (email.isEmpty || senha.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha email e palavra-passe')));
      return;
    }

    //validação do email - LOGIN LOCAL SEM BACKEND
    setState(() => _isLoading = true);
    debugPrint('Login local: email=$email');

    try {
      // Simular delay de rede
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Guardar dados localmente (login local sem backend)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'local_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setInt('user_id', 1);
      await prefs.setString('user_email', email);
      
      debugPrint('Login local bem-sucedido');
      
      //depois de guardar os dados muda a rota atual para menu
      if (!context.mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Menu()));
    } catch (err) {
      if (!context.mounted) return;
      final msg = err.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $msg')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }




//layout iniciar sessão
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Iniciar sessão',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          EmailField(controller: _emailController, backgroundColor: widget.bg),
          const SizedBox(height: 12),

          PasswordField(controller: _passwordController, backgroundColor: widget.bg),
          const SizedBox(height: 16),

          AuthActions(
            isLoading: _isLoading,
            onLoginPressed: _handleLogin,
            loginColor: widget.loginColor,
            recoverColor: widget.recoverColor,
          ),
        ],
      ),
    );
  }
}
