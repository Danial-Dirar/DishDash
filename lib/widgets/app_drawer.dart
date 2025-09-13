import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String userType; // 'user' or 'company'

  const AppDrawer({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App Name
                  const Text(
                    'DishDash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // User Type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userType == 'company' ? 'Restaurant Owner' : 'Food Lover',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (userType == 'user') ...[
                    _buildMenuItem(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Home',
                      onTap: () => Navigator.pushReplacementNamed(context, '/user-dashboard'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.bookmark_outline,
                      title: 'Saved Offers',
                      onTap: () => Navigator.pushNamed(context, '/savedoffers'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.history_outlined,
                      title: 'Order History',
                      onTap: () => Navigator.pushNamed(context, '/order-history'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.search_outlined,
                      title: 'Search',
                      onTap: () => Navigator.pushNamed(context, '/search'),
                    ),
                  ] else ...[
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      onTap: () => Navigator.pushReplacementNamed(context, '/company-dashboard'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.local_offer_outlined,
                      title: 'Post Offer',
                      onTap: () => Navigator.pushNamed(context, '/postoffer'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.article_outlined,
                      title: 'My Offers',
                      onTap: () => Navigator.pushNamed(context, '/myposts'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.restaurant_menu_outlined,
                      title: 'Menu Management',
                      onTap: () => Navigator.pushNamed(context, '/menu'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.analytics_outlined,
                      title: 'Analytics',
                      onTap: () => Navigator.pushNamed(context, '/analytics'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.business_outlined,
                      title: 'Restaurant Info',
                      onTap: () => Navigator.pushNamed(context, '/editcompanyinfo'),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 8),
                  
                  // Common Menu Items
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () => Navigator.pushNamed(context, '/help'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () => Navigator.pushNamed(context, '/about'),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.policy_outlined,
                    title: 'Terms & Privacy',
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                  ),
                ],
              ),
            ),
            
            // Logout Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  // App Version
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red[200]!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[600],
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          onTap();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout from DishDash?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
