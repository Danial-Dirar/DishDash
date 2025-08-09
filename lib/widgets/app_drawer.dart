import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';

class AppDrawer extends StatelessWidget {
  final String userType; // 'user' or 'company'
  const AppDrawer({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepOrange),
            child: Text(
              'DishDash Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          if (userType == 'company') ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Company Info'),
              onTap: () {
                Navigator.pushNamed(context, '/editcompanyinfo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Post an Offer'),
              onTap: () {
                Navigator.pushNamed(context, '/postoffer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('My Posts'),
              onTap: () {
                Navigator.pushNamed(context, '/myposts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu'),
              onTap: () {
                Navigator.pushNamed(context, '/menu');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Help & Support'),
                  content: Text(
                    'For help, contact us at support@dishdash.com.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Terms & Policies'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Terms & Policies'),
                  content: Text(
                    'Your use of this app is subject to our policies.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About DishDash'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('About DishDash'),
                  content: Text(
                    'DishDash helps you discover restaurant offers nearby.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
