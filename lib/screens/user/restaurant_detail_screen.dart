// lib/user/restaurant_detail_screen.dart

import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Assume that restaurant info is passed as argument
    final Map<String, dynamic> restaurant =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(restaurant['name'] ?? 'Restaurant Detail')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              restaurant['menuImage'] ?? 'https://via.placeholder.com/300',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              restaurant['name'] ?? '',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Offers:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(restaurant['offers']?.length ?? 0, (index) {
              final offer = restaurant['offers'][index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    offer['image'] ?? 'https://via.placeholder.com/50',
                  ),
                  title: Text(offer['title'] ?? ''),
                  subtitle: Text(offer['description'] ?? ''),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
