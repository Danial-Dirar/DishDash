import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'welcome_screen.dart';
import 'user/user_dashboard_screen.dart';
import 'company/company_dashboard_screen.dart';

/// App entry point. Keeps users signed in across launches and sends them to the
/// correct home based on their role (foodie vs restaurant owner).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authState,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        if (!authSnap.hasData) {
          return const WelcomeScreen();
        }
        // Signed in — resolve the role before choosing a dashboard.
        return FutureBuilder<String>(
          future: AuthService.roleFor(authSnap.data!.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const _Splash();
            }
            return roleSnap.data == 'owner'
                ? const CompanyDashboardScreen()
                : const UserDashboardScreen();
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 72, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'DishDash',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
