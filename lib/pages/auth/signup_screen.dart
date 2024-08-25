import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                )),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                await Provider.of<AuthProvider>(context, listen: false)
                    .signUp(email, password, name);
                Navigator.of(context).pop(); // Go back to login screen
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/auth/login');
              },
              child: const Text('Already have an account? Login here'),
            ),
          ],
        ),
      ),
    );
  }
}
