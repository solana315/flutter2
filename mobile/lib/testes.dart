import 'package:flutter/material.dart';

class TestesPage extends StatefulWidget {
	const TestesPage({super.key});

	@override
	State<TestesPage> createState() => _TestesPageState();
}

class _TestesPageState extends State<TestesPage> {
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Testes')),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							TextField(
								controller: _emailController,
								keyboardType: TextInputType.emailAddress,
								decoration: const InputDecoration(
									labelText: 'Email',
									prefixIcon: Icon(Icons.email_outlined),
								),
							),
							const SizedBox(height: 12),
							TextField(
								controller: _passwordController,
								obscureText: true,
								decoration: const InputDecoration(
									labelText: 'Password',
									prefixIcon: Icon(Icons.lock_outline),
								),
							),
							const SizedBox(height: 16),
							SizedBox(
								height: 46,
								child: ElevatedButton(
									onPressed: () {
									print("button clicked");
									},
									child: const Text('Login'),
								),
							),
						],
					),
				),
			),
		);
	}
}

