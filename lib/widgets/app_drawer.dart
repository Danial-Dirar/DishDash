import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_notifier.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/image_helper.dart';
import '../screens/auth_gate.dart';

class AppDrawer extends StatelessWidget {
  final String userType; // 'user' or 'company'

  const AppDrawer({super.key, required this.userType});

  bool get _isCompany => userType == 'company';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          // Live profile header
          StreamBuilder<AppUser?>(
            stream: AuthService.profileStream(),
            builder: (context, snap) {
              final user = snap.data;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: user?.photoBase64 != null
                          ? Base64Image(
                              base64: user!.photoBase64,
                              width: 64,
                              height: 64,
                            )
                          : Icon(
                              _isCompany ? Icons.storefront : Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.displayName ?? 'DishDash',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isCompany ? 'Restaurant Owner' : 'Food Lover',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (!_isCompany) ...[
                  _item(context, Icons.home_outlined, 'Home', '/user-dashboard',
                      replace: true),
                  _item(context, Icons.bookmark_outline, 'Saved Offers',
                      '/saved-offers'),
                ] else ...[
                  _item(context, Icons.dashboard_outlined, 'Dashboard',
                      '/company-dashboard', replace: true),
                  _item(context, Icons.add_business_outlined, 'Post Offer',
                      '/postoffer'),
                  _item(context, Icons.article_outlined, 'My Offers', '/myposts'),
                  _item(context, Icons.restaurant_menu_outlined, 'Menu', '/menu'),
                  _item(context, Icons.business_outlined, 'Restaurant Info',
                      '/editcompanyinfo'),
                ],

                const Divider(height: 24),

                // Dark mode toggle
                Consumer<ThemeNotifier>(
                  builder: (context, notifier, _) => SwitchListTile(
                    secondary: Icon(
                      notifier.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Dark mode'),
                    value: notifier.isDarkMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: notifier.toggleTheme,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'DishDash v1.0.0',
                  style: TextStyle(color: AppColors.subtleText(context), fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                      foregroundColor: AppColors.danger,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    bool replace = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.subtleText(context)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        if (replace) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from DishDash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
