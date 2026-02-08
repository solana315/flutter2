import 'package:flutter/material.dart';
//textfields logine email


/// EMAIL textfiels
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final Color backgroundColor;

  const EmailField({super.key, required this.controller, this.backgroundColor = const Color(0xFFFAF7F4)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
    );
  }
}

///PASSWORD textfield
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final Color backgroundColor;

  const PasswordField({super.key, required this.controller, this.backgroundColor = const Color(0xFFFAF7F4)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Palavra-passe',
          prefixIcon: Icon(Icons.lock_outline),
        ),
      ),
    );
  }
}
