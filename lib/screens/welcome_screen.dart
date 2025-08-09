import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DishDash')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to DishDash',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signupchoice');
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/guest');
              },
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
