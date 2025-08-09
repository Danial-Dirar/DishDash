import 'package:flutter/material.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registercompany');
              },
              child: const Text('Register as Company'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registeruser');
              },
              child: const Text('Register as User'),
            ),
          ],
        ),
      ),
    );
  }
}
