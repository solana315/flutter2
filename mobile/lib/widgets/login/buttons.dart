import 'package:flutter/material.dart';
//botoes entrar e recuperar palavra passe


///Recover Password button
class RecoverPasswordButton extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;

  const RecoverPasswordButton({
    super.key,
    this.backgroundColor = const Color(0xFFF3EDE7),
    this.foregroundColor = Colors.black87,
    this.label = 'Recuperar Palavra-passe',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recuperar Palavra-passe')),
          );
        },
        child: Text(label),
      ),
    );
  }
}


///BOTAO ENTRAR
class AuthActions extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function()? onLoginPressed;
  final Color loginColor;
  final Color recoverColor;

  const AuthActions({
    super.key,
    required this.isLoading,
    required this.onLoginPressed,
    this.loginColor = const Color(0xFFA87B05),
    this.recoverColor = const Color(0xFFF3EDE7),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: loginColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isLoading || onLoginPressed == null
                ? null
                : () {
                    onLoginPressed!();
                  },
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Entrar', style: TextStyle(color: Colors.white)),
          ),
        ),

        const SizedBox(height: 12),

        RecoverPasswordButton(backgroundColor: recoverColor),
      ],
    );
  }
}
