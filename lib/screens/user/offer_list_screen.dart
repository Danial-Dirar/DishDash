// lib/user/offer_list_screen.dart

import 'package:flutter/material.dart';

class OfferListScreen extends StatelessWidget {
  const OfferListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This should come from your backend or dummy list for now
    List<Map<String, String>> offers = [
      {
        'title': '20% Off Pizza!',
        'thumbnail': 'https://via.placeholder.com/150',
      },
      {
        'title': 'Buy 1 Get 1 Free!',
        'thumbnail': 'https://via.placeholder.com/150',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Offers Near You')),
      body: ListView.builder(
        itemCount: offers.length,
        itemBuilder: (context, index) {
          var offer = offers[index];
          return Card(
            child: ListTile(
              leading: Image.network(
                offer['thumbnail']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(offer['title']!),
              onTap: () {
                Navigator.pushNamed(context, '/offer-detail', arguments: offer);
              },
            ),
          );
        },
      ),
    );
  }
}
