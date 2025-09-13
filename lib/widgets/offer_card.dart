import 'package:flutter/material.dart';

class OfferCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
