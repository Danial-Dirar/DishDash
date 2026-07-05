import 'package:flutter/material.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join DishDash'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header text
                const Text(
                  'Choose Your Account Type',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Select how you want to use DishDash',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Restaurant/Company Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/registercompany');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.store,
                              size: 40,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Restaurant Owner',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'Post offers and manage your restaurant profile',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'For Businesses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // User/Customer Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/registeruser');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7931E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFFF7931E),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Food Lover',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF7931E),
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'Discover and save amazing food offers near you',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7931E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'For Customers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Already have account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signin');
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFFFF6B35),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
