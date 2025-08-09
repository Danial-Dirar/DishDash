import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';

class CompanyDashboardScreen extends StatelessWidget {
  final String companyName;

  const CompanyDashboardScreen({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$companyName Dashboard'),
        backgroundColor: Colors.deepOrange,
      ),
      drawer: const AppDrawer(userType: 'company'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDashboardButton(
              context,
              icon: Icons.edit,
              label: 'Edit Company Info',
              routeName: '/editcompanyinfo',
            ),
            _buildDashboardButton(
              context,
              icon: Icons.local_offer,
              label: 'Post an Offer',
              routeName: '/postoffer',
            ),
            _buildDashboardButton(
              context,
              icon: Icons.article,
              label: 'My Posts',
              routeName: '/myposts',
            ),
            _buildDashboardButton(
              context,
              icon: Icons.restaurant_menu,
              label: 'Menu',
              routeName: '/menu',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
