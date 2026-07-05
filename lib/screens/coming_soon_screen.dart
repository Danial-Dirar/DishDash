import 'package:flutter/material.dart';

/// Graceful fallback shown for routes that are referenced in the UI but not yet
/// implemented (e.g. Settings, Help, Analytics). Prevents the app from crashing
/// with a "Could not find a generator for route" error when such a link is
/// tapped, and clearly communicates the feature is on the way.
class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  /// Turns a route name like "/order-history" into a readable "Order History".
  static String titleFromRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) return 'Coming Soon';
    final cleaned = routeName.replaceAll('/', '').replaceAll(RegExp(r'[-_]'), ' ').trim();
    if (cleaned.isEmpty) return 'Coming Soon';
    return cleaned
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.rocket_launch_outlined,
                size: 96,
                color: Color(0xFFFF6B35),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This feature is coming soon. Stay tuned!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
